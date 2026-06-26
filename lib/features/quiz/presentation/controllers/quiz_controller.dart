import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/features/quiz/data/quiz_database.dart';
import 'package:adeen/features/quiz/domain/quiz_question.dart';
import 'package:adeen/features/quiz/data/quiz_translator.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class QuizState {
  final Set<int> answeredQuestionIds;
  final List<QuizQuestion> currentDailyQuestions;
  final Map<int, int> selectedAnswers; // questionId -> optionIndex
  final int totalPoints;
  final bool isCompletedToday;
  final bool isLoading;
  final bool isSyncing;
  final bool? syncSuccess;
  final String? syncError;

  const QuizState({
    required this.answeredQuestionIds,
    required this.currentDailyQuestions,
    required this.selectedAnswers,
    required this.totalPoints,
    required this.isCompletedToday,
    this.isLoading = false,
    this.isSyncing = false,
    this.syncSuccess,
    this.syncError,
  });

  QuizState copyWith({
    Set<int>? answeredQuestionIds,
    List<QuizQuestion>? currentDailyQuestions,
    Map<int, int>? selectedAnswers,
    int? totalPoints,
    bool? isCompletedToday,
    bool? isLoading,
    bool? isSyncing,
    bool? syncSuccess,
    String? syncError,
  }) {
    return QuizState(
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
      currentDailyQuestions: currentDailyQuestions ?? this.currentDailyQuestions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      totalPoints: totalPoints ?? this.totalPoints,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      syncSuccess: syncSuccess ?? this.syncSuccess,
      syncError: syncError ?? this.syncError,
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  final String languageCode;
  final Dio _dio = Dio();
  static const String _syncEndpoint = 'https://adeen-backend.test/api/v1/user/quiz-sync'; // Placeholder/config URL

  QuizController(this.languageCode)
      : super(const QuizState(
          answeredQuestionIds: {},
          currentDailyQuestions: [],
          selectedAnswers: {},
          totalPoints: 0,
          isCompletedToday: false,
        )) {
    initQuiz();
  }

  /// Initial loads, daily question generation, and progress restoration
  Future<void> initQuiz() async {
    state = state.copyWith(isLoading: true);
    
    // 1. Load answered question IDs from Hive
    final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);
    final Set<int> answeredIds = answeredBox.keys.cast<int>().toSet();

    // 2. Load total points
    final int points = DatabaseService.getQuizTotalPoints();

    // 3. Load daily generation details
    final settingsBox = DatabaseService.getBox(DatabaseService.settingsBoxName);
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final String? savedDate = settingsBox.get('quiz_daily_date') as String?;
    final List<dynamic>? savedIdsRaw = settingsBox.get('quiz_daily_ids') as List<dynamic>?;
    final List<int> savedIds = savedIdsRaw != null ? List<int>.from(savedIdsRaw) : [];

    List<QuizQuestion> dailyQuestions = [];

    if (savedDate == todayStr && savedIds.isNotEmpty) {
      // Restore questions from saved IDs for today
      dailyQuestions = quizQuestionsDb.where((q) => savedIds.contains(q.id)).toList();
      // Keep structural ordering matching the saved list
      dailyQuestions.sort((a, b) => savedIds.indexOf(a.id).compareTo(savedIds.indexOf(b.id)));
    } else {
      // New day: select 7 new questions
      dailyQuestions = await _generateNewDailySet(answeredIds, settingsBox, todayStr);
    }

    // 4. Translate questions if language is not English
    List<QuizQuestion> translatedQuestions = [];
    if (languageCode != 'en') {
      try {
        for (var q in dailyQuestions) {
          final trans = await QuizTranslator.translateQuestion(q, languageCode);
          translatedQuestions.add(trans);
        }
      } catch (e) {
        translatedQuestions = dailyQuestions;
      }
    } else {
      translatedQuestions = dailyQuestions;
    }

    // 5. Restore selected answers from Hive settings box
    final Map<dynamic, dynamic>? savedAnswersRaw = settingsBox.get('quiz_daily_answers') as Map<dynamic, dynamic>?;
    final Map<int, int> savedAnswers = savedAnswersRaw != null
        ? savedAnswersRaw.map((k, v) => MapEntry(k as int, v as int))
        : {};

    // 6. Determine if completed today using original IDs
    bool completedToday = dailyQuestions.isNotEmpty &&
        dailyQuestions.every((q) => answeredIds.contains(q.id));

    state = state.copyWith(
      answeredQuestionIds: answeredIds,
      currentDailyQuestions: translatedQuestions,
      totalPoints: points,
      isCompletedToday: completedToday,
      selectedAnswers: savedAnswers,
      isLoading: false,
    );
  }

  /// Selects 7 unanswered questions from the database. Shuffles to randomise.
  /// If the remaining pool is smaller than 7, resets the answered history and draws from all.
  Future<List<QuizQuestion>> _generateNewDailySet(Set<int> answeredIds, var settingsBox, String todayStr) async {
    List<QuizQuestion> unanswered = quizQuestionsDb.where((q) => !answeredIds.contains(q.id)).toList();

    if (unanswered.length < 7) {
      // Recycle the pool: clear the answered list
      final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);
      await answeredBox.clear();
      answeredIds.clear();
      unanswered = List.from(quizQuestionsDb);
    }

    // Shuffle and pick 7
    unanswered.shuffle();
    final List<QuizQuestion> selected = unanswered.take(7).toList();
    final List<int> selectedIds = selected.map((q) => q.id).toList();

    // Persist today's chosen questions and clean answers for the new set
    await settingsBox.put('quiz_daily_date', todayStr);
    await settingsBox.put('quiz_daily_ids', selectedIds);
    await settingsBox.delete('quiz_daily_answers');

    return selected;
  }

  /// Store user response during the active quiz session
  void selectAnswer(int questionId, int optionIndex) {
    final updated = Map<int, int>.from(state.selectedAnswers);
    updated[questionId] = optionIndex;
    state = state.copyWith(selectedAnswers: updated);
    
    final settingsBox = DatabaseService.getBox(DatabaseService.settingsBoxName);
    settingsBox.put('quiz_daily_answers', updated);
  }

  /// Completes the session: calculates final score, persists to Hive, and syncs
  Future<void> submitQuiz() async {
    if (state.isCompletedToday) return;

    state = state.copyWith(isSyncing: true, syncError: null, syncSuccess: null);

    // Calculate score
    int gainedPoints = 0;
    final Set<int> newlyAnsweredIds = Set.from(state.answeredQuestionIds);
    final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);

    for (var q in state.currentDailyQuestions) {
      final selected = state.selectedAnswers[q.id];
      if (selected == q.correctOptionIndex) {
        gainedPoints += q.points;
      }
      
      // Persist to local answered list
      newlyAnsweredIds.add(q.id);
      await answeredBox.put(q.id, true);
    }

    final int updatedTotalPoints = state.totalPoints + gainedPoints;
    await DatabaseService.saveQuizTotalPoints(updatedTotalPoints);

    state = state.copyWith(
      answeredQuestionIds: newlyAnsweredIds,
      totalPoints: updatedTotalPoints,
      isCompletedToday: true,
      isSyncing: false,
    );

    // Sync with Laravel server in background
    await syncWithLaravel();
  }

  /// Sends stats and answered logs to Laravel backend
  Future<void> syncWithLaravel() async {
    state = state.copyWith(isSyncing: true, syncError: null, syncSuccess: null);

    try {
      final response = await _dio.post(
        _syncEndpoint,
        data: {
          'total_points': state.totalPoints,
          'answered_ids': state.answeredQuestionIds.toList(),
          'synced_at': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isSyncing: false, syncSuccess: true);
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } on DioException catch (dioErr) {
      String errMsg = 'quiz_sync_error_failed';
      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.sendTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        errMsg = 'quiz_sync_error_timeout';
      }
      state = state.copyWith(
        isSyncing: false,
        syncSuccess: false,
        syncError: errMsg,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncSuccess: false,
        syncError: 'quiz_sync_error_failed',
      );
    }
  }

  /// Resets daily quiz state for testing purposes or debug recycling
  Future<void> debugResetQuiz() async {
    final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);
    await answeredBox.clear();

    final translationsBox = DatabaseService.getBox(DatabaseService.quizTranslationsBoxName);
    await translationsBox.clear();

    final settingsBox = DatabaseService.getBox(DatabaseService.settingsBoxName);
    await settingsBox.delete('quiz_daily_date');
    await settingsBox.delete('quiz_daily_ids');
    await settingsBox.delete('quiz_daily_answers');
    await DatabaseService.saveQuizTotalPoints(0);

    initQuiz();
  }
}

final quizStateProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  final locale = ref.watch(localeProvider);
  return QuizController(locale.languageCode);
});
