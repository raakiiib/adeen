import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/quiz/domain/quiz_question.dart';
import 'package:adeen/features/quiz/data/quiz_database.dart';
import 'package:adeen/features/quiz/presentation/controllers/quiz_controller.dart';

class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary),
        ),
      );
    }

    final questions = state.currentDailyQuestions;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('tafsir_review'),
          style: TextStyle(
            
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Force them to use home/done button
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Server Sync Status Bar
            _buildSyncStatusHeader(context, theme, state),

            // 2. Questions Tafsir Review List
            Expanded(
              child: questions.isEmpty
                  ? Center(
                      child: Text(localizations.translate('quiz_no_results')),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final userAnsIndex = state.selectedAnswers[q.id];
                        final isCorrect = userAnsIndex == q.correctOptionIndex;

                        return _buildTafsirItem(
                          context,
                          theme,
                          isDark,
                          index + 1,
                          q,
                          userAnsIndex,
                          isCorrect,
                        );
                      },
                    ),
            ),

            // 3. Bottom Close Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: 0,
                ),
                child: Text(
                  localizations.translate('back_to_home'),
                  style: TextStyle(
                    
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusHeader(
    BuildContext context,
    ThemeData theme,
    QuizState state,
  ) {
    final localizations = AppLocalizations.of(context);
    if (state.isSyncing) {
      return Container(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              localizations.translate('quiz_syncing'),
              style: TextStyle(
                
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    if (state.syncSuccess == true) {
      return Container(
        color: Colors.green.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              localizations.translate('quiz_synced'),
              style: TextStyle(
                
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    if (state.syncError != null) {
      return Container(
        color: Colors.amber.withOpacity(0.12),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.translate(state.syncError!),
                style: TextStyle(
                  
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTafsirItem(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    int index,
    QuizQuestion q,
    int? userAnsIndex,
    bool isCorrect,
  ) {
    debugPrint(
      'Building Tafsir Item $index: Question: "${q.question}", Tafsir: "${q.tafsirInsight}"',
    );
    final localizations = AppLocalizations.of(context);

    // Fallback to original English values if translation returned empty/null
    QuizQuestion displayQ = q;
    final cleanTafsir = q.tafsirInsight.trim();
    if (cleanTafsir.isEmpty ||
        cleanTafsir.toLowerCase() == 'null' ||
        q.question.trim().isEmpty) {
      try {
        final original = quizQuestionsDb.firstWhere(
          (element) => element.id == q.id,
        );
        displayQ = QuizQuestion(
          id: q.id,
          category: q.category.trim().isEmpty ? original.category : q.category,
          difficulty: q.difficulty,
          points: q.points,
          question: q.question.trim().isEmpty ? original.question : q.question,
          options: q.options.any((o) => o.trim().isEmpty)
              ? original.options
              : q.options,
          correctOptionIndex: q.correctOptionIndex,
          tafsirInsight:
              cleanTafsir.isEmpty || cleanTafsir.toLowerCase() == 'null'
              ? original.tafsirInsight
              : q.tafsirInsight,
        );
      } catch (_) {
        // fallback failed, keep using q
      }
    }

    // Double check that we have a valid text to display. If still empty, grab original dynamically.
    String tafsirToDisplay = displayQ.tafsirInsight.trim();
    if (tafsirToDisplay.isEmpty || tafsirToDisplay.toLowerCase() == 'null') {
      try {
        final original = quizQuestionsDb.firstWhere(
          (element) => element.id == q.id,
        );
        tafsirToDisplay = original.tafsirInsight;
      } catch (_) {
        tafsirToDisplay = 'No Tafsir available for this question.';
      }
    }

    // Elegant review card for each question
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Index & category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizations.translate('quiz_question_count').toUpperCase()} ${localizations.localizeDigits(index.toString())}',
                style: TextStyle(
                  
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isCorrect ? Colors.green : Colors.amber).withOpacity(
                    0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isCorrect ? Colors.green : Colors.amber)
                        .withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check : Icons.close,
                      size: 10,
                      color: isCorrect ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect
                          ? localizations.translate('quiz_correct')
                          : localizations.translate('quiz_incorrect'),
                      style: TextStyle(
                        
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Text
          Text(
            displayQ.question,
            style: theme.textTheme.titleMedium?.copyWith(
              
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Options and highlighting
          ...displayQ.options.asMap().entries.map((entry) {
            final optIndex = entry.key;
            final optText = entry.value;

            final isCorrectOption = optIndex == displayQ.correctOptionIndex;
            final isUserChoice = optIndex == userAnsIndex;

            Color bgColor = Colors.transparent;
            Color borderColor = theme.dividerColor;
            Widget? suffixIcon;

            if (isCorrectOption) {
              bgColor = isDark
                  ? const Color(0xFF0F2D1D)
                  : const Color(0xFFE8F5E9);
              borderColor = Colors.green.shade400;
              suffixIcon = Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              );
            } else if (isUserChoice) {
              // User selected this but it was incorrect
              bgColor = isDark
                  ? const Color(0xFF381515)
                  : const Color(0xFFFFEBEE);
              borderColor = Colors.red.shade300;
              suffixIcon = Icon(
                Icons.cancel,
                color: Colors.red.shade400,
                size: 16,
              );
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      optText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: (isCorrectOption || isUserChoice)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCorrectOption
                            ? Colors.green.shade700
                            : isUserChoice
                            ? Colors.red.shade700
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  if (suffixIcon != null) suffixIcon,
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // Padded, Book-Like container for Tafsir Insight
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1A16) : const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  localizations.translate('quiz_tafsir_insight'),
                                  style: TextStyle(
                                    
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tafsirToDisplay,
                              style: (theme.textTheme.bodyLarge ?? TextStyle())
                                  .copyWith(
                                    
                                    fontSize: 13,
                                    fontStyle: localizations.locale.languageCode == 'en'
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    height: 1.45,
                                    color: theme.textTheme.bodyLarge?.color ??
                                        theme.colorScheme.onSurface,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
