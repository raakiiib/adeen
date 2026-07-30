import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:adeen/features/quiz/presentation/screens/quiz_results_screen.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  const QuizSessionScreen({super.key});

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    if (state.isCompletedToday) {
      return _buildCompletedTodayDashboard(context, theme, isDark, state, localizations);
    }

    final questions = state.currentDailyQuestions;
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            localizations.translate('quiz'),
            style: TextStyle(),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(height: 16),
                Text(
                  localizations.translate('no_questions_available'),
                  style: theme.textTheme.titleLarge?.copyWith(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.translate('no_questions_available_sub'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = questions[_currentPageIndex];
    final selectedOption = state.selectedAnswers[currentQuestion.id];
    final isLastQuestion = _currentPageIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('quiz'),
          style: TextStyle(
            
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, size: 16, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${localizations.localizeDigits(state.totalPoints.toString())} ${localizations.translate('quiz_pts')}',
                      style: TextStyle(
                        
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Progress Bar Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${localizations.translate('quiz_question_count')} ${localizations.localizeDigits((_currentPageIndex + 1).toString())} ${localizations.translate('of_total')} ${localizations.localizeDigits(questions.length.toString())}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${currentQuestion.points} ${localizations.translate('quiz_points')}',
                        style: TextStyle(
                          
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentPageIndex + 1) / questions.length,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? theme.colorScheme.surface
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Question View Page
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force users to use buttons
                itemCount: questions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, qIndex) {
                  final q = questions[qIndex];
                  final ans = state.selectedAnswers[q.id];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card with Islamic Frame Drawing
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.dividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: IslamicArchPainter(
                                    outlineColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.06),
                                    fillColor: Colors.transparent,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        q.category.toUpperCase(),
                                        style: TextStyle(
                                          
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      q.question,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Interactive Option Items
                        ...q.options.asMap().entries.map((entry) {
                          final int optIndex = entry.key;
                          final String optText = entry.value;
                          final bool isSelectedOpt = ans == optIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                ref.read(quizStateProvider.notifier).selectAnswer(q.id, optIndex);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelectedOpt
                                      ? Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                                      : theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelectedOpt
                                        ? Theme.of(context).colorScheme.primary
                                        : theme.dividerColor,
                                    width: isSelectedOpt ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelectedOpt
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelectedOpt
                                              ? Theme.of(context).colorScheme.primary
                                              : theme.dividerColor,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        String.fromCharCode(65 + optIndex), // A, B, C, D
                                        style: TextStyle(
                                          
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelectedOpt
                                              ? Colors.white
                                              : theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        optText,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isSelectedOpt ? FontWeight.bold : FontWeight.w500,
                                          color: isSelectedOpt
                                              ? Theme.of(context).colorScheme.primary
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. Navigation Controls Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPageIndex > 0
                      ? OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            localizations.translate('quiz_previous'),
                            style: TextStyle(
                              
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Next / Submit button
                  ElevatedButton(
                    onPressed: selectedOption == null
                        ? null
                        : () async {
                            if (isLastQuestion) {
                              // Perform submissions
                              await ref.read(quizStateProvider.notifier).submitQuiz();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const QuizResultsScreen()),
                                );
                              }
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isLastQuestion ? localizations.translate('quiz_finish') : localizations.translate('quiz_next'),
                      style: TextStyle(
                        
                        fontWeight: FontWeight.bold,
                        color: selectedOption == null
                            ? Colors.white.withOpacity(0.5)
                            : (isDark ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTodayDashboard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    QuizState state,
    AppLocalizations localizations,
  ) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('quiz'),
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Arch container with victory icons
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: IslamicArchPainter(
                          outlineColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                          fillColor: Colors.transparent,
                          strokeWidth: 2.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events_outlined, size: 72, color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(height: 16),
                          Text(
                            localizations.translate('quiz_completed_title'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              localizations.translate('quiz_completed_sub'),
                              textAlign: TextAlign.center,
                              style: TextStyle(height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Score stats
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  localizations.translate('quiz_lifetime_score'),
                                  style: TextStyle(
                                    
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${localizations.localizeDigits(state.totalPoints.toString())} ${localizations.translate('quiz_points')}',
                                  style: TextStyle(
                                    
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Button to open Results
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizResultsScreen()),
                  );
                },
                icon: Icon(Icons.chrome_reader_mode_outlined, color: Color(0xFF0B2A18)),
                label: Text(
                  localizations.translate('tafsir_review'),
                  style: TextStyle(
                    
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0B2A18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),

              // Debug reset (only if in developer/local environment)
              TextButton(
                onPressed: () async {
                  await ref.read(quizStateProvider.notifier).debugResetQuiz();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Quiz progress reset for debugging!')),
                    );
                  }
                },
                child: Text(
                  'Debug Reset Quiz',
                  style: TextStyle(
                    
                    fontSize: 12,
                    color: Colors.redAccent.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
