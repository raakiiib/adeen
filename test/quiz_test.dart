import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/features/quiz/domain/quiz_question.dart';
import 'package:adeen/features/quiz/data/quiz_database.dart';
import 'package:adeen/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:adeen/features/quiz/data/quiz_translator.dart';

void main() {
  group('Daily Quranic Quiz Unit Tests', () {
    test('All 100 questions in database have valid fields and non-empty tafsirInsight', () {
      final database = quizQuestionsDb;
      expect(database.length, 100);
      for (final q in database) {
        expect(q.id, isNotNull);
        expect(q.category, isNotEmpty);
        expect(q.question, isNotEmpty);
        expect(q.options.length, 4);
        for (final opt in q.options) {
          expect(opt, isNotEmpty);
        }
        expect(q.correctOptionIndex >= 0, true);
        expect(q.correctOptionIndex, lessThan(4));
        expect(q.tafsirInsight, isNotEmpty);
        expect(q.tafsirInsight.trim(), isNotEmpty);
      }
    });
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      await Hive.openBox(DatabaseService.settingsBoxName);
      await Hive.openBox(DatabaseService.answeredQuizzesBoxName);
      await Hive.openBox(DatabaseService.quizTranslationsBoxName);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('QuizQuestion model parses from JSON and serializes to JSON correctly', () {
      final jsonMap = {
        'id': 999,
        'category': 'Test Category',
        'difficulty': 'Hard',
        'points': 25,
        'question': 'What is the test question?',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correct_option_index': 2,
        'tafsir_insight': 'Insight information here.'
      };

      final question = QuizQuestion.fromJson(jsonMap);

      expect(question.id, 999);
      expect(question.category, 'Test Category');
      expect(question.difficulty, 'Hard');
      expect(question.points, 25);
      expect(question.question, 'What is the test question?');
      expect(question.options, ['Option A', 'Option B', 'Option C', 'Option D']);
      expect(question.correctOptionIndex, 2);
      expect(question.tafsirInsight, 'Insight information here.');

      final serialized = question.toJson();
      expect(serialized['id'], 999);
      expect(serialized['category'], 'Test Category');
      expect(serialized['correct_option_index'], 2);
    });

    test('QuizController initializes, selects 7 questions, and handles selections', () async {
      final container = ProviderContainer();
      try {
        final controller = container.read(quizStateProvider.notifier);
        await controller.initQuiz();

        // Verify initialization state
        final initialState = container.read(quizStateProvider);
        expect(initialState.isLoading, false);
        expect(initialState.isCompletedToday, false);
        expect(initialState.totalPoints, 0);
        expect(initialState.currentDailyQuestions.length, 7);
        expect(initialState.selectedAnswers, isEmpty);

        // Answer selection
        final firstQuestion = initialState.currentDailyQuestions[0];
        controller.selectAnswer(firstQuestion.id, 1);

        final updatedState = container.read(quizStateProvider);
        expect(updatedState.selectedAnswers[firstQuestion.id], 1);
      } finally {
        container.dispose();
      }
    });

    test('QuizController submits answers, updates score, marks today completed, and saves to Hive', () async {
      final container = ProviderContainer();
      try {
        final controller = container.read(quizStateProvider.notifier);
        await controller.initQuiz();

        final stateBefore = container.read(quizStateProvider);
        final questions = stateBefore.currentDailyQuestions;

        // Select correct answer for 3 questions, incorrect for remaining 4
        int expectedPointsGained = 0;
        for (int i = 0; i < questions.length; i++) {
          final q = questions[i];
          if (i < 3) {
            controller.selectAnswer(q.id, q.correctOptionIndex);
            expectedPointsGained += q.points;
          } else {
            // Select incorrect answer
            final wrongIndex = (q.correctOptionIndex + 1) % 4;
            controller.selectAnswer(q.id, wrongIndex);
          }
        }

        // Submit
        await controller.submitQuiz();

        final stateAfter = container.read(quizStateProvider);
        expect(stateAfter.isCompletedToday, true);
        expect(stateAfter.totalPoints, expectedPointsGained);

        // Verify persistence in Hive answered_quizzes box
        final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);
        for (final q in questions) {
          expect(answeredBox.get(q.id), true);
        }

        // Verify points saved in settings box
        expect(DatabaseService.getQuizTotalPoints(), expectedPointsGained);
      } finally {
        container.dispose();
      }
    });

    test('QuizController recycles answered questions when pool is exhausted', () async {
      final container = ProviderContainer();
      try {
        final controller = container.read(quizStateProvider.notifier);
        await controller.initQuiz();

        // Pre-fill Hive answered box with 98 answered question IDs
        final answeredBox = DatabaseService.getBox(DatabaseService.answeredQuizzesBoxName);
        for (int i = 1; i <= 98; i++) {
          await answeredBox.put(i, true);
        }

        // Clear saved daily settings so it forces a new daily set generation
        final settingsBox = DatabaseService.getBox(DatabaseService.settingsBoxName);
        await settingsBox.delete('quiz_daily_date');
        await settingsBox.delete('quiz_daily_ids');

        // Re-initialize quiz (which triggers pool exhaustion recycling check)
        await controller.initQuiz();

        final state = container.read(quizStateProvider);
        
        // Since 98 out of 100 questions were answered, only 2 remain unanswered.
        // 2 is less than 7, so the controller must clear the answered list (recycle the pool).
        // Verify that new daily set of 7 questions was successfully selected.
        expect(state.currentDailyQuestions.length, 7);
        
        // The answered set should be empty after recycling
        expect(answeredBox.isEmpty, true);
      } finally {
        container.dispose();
      }
    });

    test('QuizTranslator caches and returns translated strings or fallback to original', () async {
      // Direct cache write check
      final box = Hive.box(DatabaseService.quizTranslationsBoxName);
      final cacheKey = 'ar_${'Tafsir'.hashCode}';
      await box.put(cacheKey, 'التفسير');

      final translated = await QuizTranslator.translateText('Tafsir', 'ar');
      expect(translated, 'التفسير');

      // Test fallback behavior for un-cached item during network isolation
      final untranslated = await QuizTranslator.translateText('Nonexistent word', 'bn');
      expect(untranslated == 'Nonexistent word' || untranslated == 'অস্তিত্বহীন শব্দ', true);
    });
  });
}
