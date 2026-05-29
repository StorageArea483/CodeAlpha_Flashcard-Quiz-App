import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_card_quiz/providers/test_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class TakeTest extends ConsumerStatefulWidget {
  final String testName;
  const TakeTest({super.key, required this.testName});

  @override
  ConsumerState<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends ConsumerState<TakeTest> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuestionsFromFirestore();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQuestionsFromFirestore() async {
    try {
      if (mounted) {
        ref.read(testInfoProvider.notifier).setLoading(true);
      }

      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('quizinfo')
          .where('testName', isEqualTo: widget.testName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No questions found for this test');
      }

      final questions = querySnapshot.docs.map((doc) {
        final data = doc.data();

        if (data['options'] == null || (data['options'] as List).isEmpty) {
          throw Exception('No options provided');
        }

        return {
          'id': doc.id,
          'question': data['question'] as String,
          'options': List<String>.from(data['options'] as List),
          'numberOfOptions': data['numberOfOptions'] as int,
          'correctOption': data['correctOption'] as String,
          'selectedTime': data['selectedTime'] as String,
          'selectedEndTime': data['selectedEndTime'] as String,
        };
      }).toList();

      if (mounted) {
        ref.read(testInfoProvider.notifier).setQuestions(questions);

        // Parse start and end times
        final firstQuestion = questions.first;
        final startTime = firstQuestion['selectedTime'] as String;
        final endTime = firstQuestion['selectedEndTime'] as String;

        final startParts = startTime.split(':');
        final endParts = endTime.split(':');

        final startMinutes =
            int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        final remainingSeconds = (endMinutes - startMinutes) * 60;
        ref
            .read(testInfoProvider.notifier)
            .setRemainingSeconds(remainingSeconds);

        // Start timer
        _startTimer();

        ref.read(testInfoProvider.notifier).setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        ref.read(testInfoProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final currentSeconds = ref.read(testInfoProvider).remainingSeconds;
      if (currentSeconds > 0 && mounted) {
        ref
            .read(testInfoProvider.notifier)
            .setRemainingSeconds(currentSeconds - 1);
      } else {
        timer.cancel();
        _submitTest();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitTest() {
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test submitted!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _nextCard() {
    if (mounted) {
      final questions = ref.read(testInfoProvider).questions;
      final currentIndex = ref.read(testInfoProvider).currentCardIndex;

      if (currentIndex < questions.length - 1) {
        ref
            .read(testInfoProvider.notifier)
            .setCurrentCardIndex(currentIndex + 1);
        ref.read(testInfoProvider.notifier).setShowAnswer(false);
      }
    }
  }

  void _previousCard() {
    if (mounted) {
      final currentIndex = ref.read(testInfoProvider).currentCardIndex;

      if (currentIndex > 0) {
        ref
            .read(testInfoProvider.notifier)
            .setCurrentCardIndex(currentIndex - 1);
        ref.read(testInfoProvider.notifier).setShowAnswer(false);
      }
    }
  }

  void _toggleAnswer() {
    if (mounted) {
      final showAnswer = ref.read(testInfoProvider).showAnswer;
      ref.read(testInfoProvider.notifier).setShowAnswer(!showAnswer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Timer Bar (Fixed at top)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remaining Time',
                            style: AppText.small.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer(
                            builder: (context, ref, child) {
                              if (!mounted) {
                                return const SizedBox.shrink();
                              }
                              final remainingSeconds = ref.watch(
                                testInfoProvider.select(
                                  (v) => v.remainingSeconds,
                                ),
                              );
                              return Text(
                                _formatTime(remainingSeconds),
                                style: AppText.base.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: remainingSeconds < 300
                                      ? AppColors.error
                                      : AppColors.primaryDark,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _submitTest,
                        style: AppButtons.primary.copyWith(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                        child: const Text('Submit', style: AppText.button),
                      ),
                    ],
                  ),
                ),

                // Flashcard Content
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      if (!mounted) return const SizedBox.shrink();
                      final questions = ref.watch(
                        testInfoProvider.select((v) => v.questions),
                      );
                      if (questions.isEmpty)
                        // ignore: curly_braces_in_flow_control_structures
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.quiz_outlined,
                                size: 64,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No questions available',
                                style: AppText.base.copyWith(
                                  color: AppColors.textLight,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Flashcard
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: SimpleDecoration.card(),
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Question Label
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Question',
                                        style: AppText.base.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Question Text
                                    Consumer(
                                      builder: (context, ref, child) {
                                        if (!mounted) {
                                          return const SizedBox.shrink();
                                        }
                                        final currentCardIndex = ref.watch(
                                          testInfoProvider.select(
                                            (v) => v.currentCardIndex,
                                          ),
                                        );
                                        return Expanded(
                                          child: Center(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                questions[currentCardIndex]['question']
                                                    as String,
                                                style: AppText.base.copyWith(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  color: AppColors.textPrimary,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Answer Section (conditionally shown)
                                    Consumer(
                                      builder: (context, ref, child) {
                                        if (!mounted) {
                                          return const SizedBox.shrink();
                                        }
                                        final showAnswer = ref.watch(
                                          testInfoProvider.select(
                                            (v) => v.showAnswer,
                                          ),
                                        );
                                        if (showAnswer == false) {
                                          return const SizedBox.shrink();
                                        }
                                        // ignore: curly_braces_in_flow_control_structures
                                        return Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.success,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Answer',
                                                style: AppText.base.copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Consumer(
                                              builder: (context, ref, child) {
                                                if (!mounted) {
                                                  return const SizedBox.shrink();
                                                }
                                                final currentCardIndex = ref
                                                    .watch(
                                                      testInfoProvider.select(
                                                        (v) =>
                                                            v.currentCardIndex,
                                                      ),
                                                    );
                                                return Text(
                                                  questions[currentCardIndex]['correctOption']
                                                      as String,
                                                  style: AppText.base.copyWith(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4,
                                                    color: AppColors.success,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Show Answer Button
                            Consumer(
                              builder: (context, ref, child) {
                                if (!mounted) {
                                  return const SizedBox.shrink();
                                }
                                final showAnswer = ref.watch(
                                  testInfoProvider.select((v) => v.showAnswer),
                                );
                                return SizedBox(
                                  width: double.infinity,
                                  height: AppSizes.primaryButtonHeight,
                                  child: ElevatedButton(
                                    onPressed: _toggleAnswer,
                                    style: AppButtons.primary,
                                    child: Text(
                                      showAnswer
                                          ? 'Hide Answer'
                                          : 'Show Answer',
                                      style: AppText.submitButton,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Navigation Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: AppSizes.primaryButtonHeight,
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        if (!mounted) {
                                          return const SizedBox.shrink();
                                        }
                                        final currentCardIndex = ref.watch(
                                          testInfoProvider.select(
                                            (v) => v.currentCardIndex,
                                          ),
                                        );
                                        return ElevatedButton.icon(
                                          onPressed: currentCardIndex > 0
                                              ? _previousCard
                                              : null,
                                          style: AppButtons.outlined.copyWith(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  AppColors.surfaceLight,
                                                ),
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            'Previous',
                                            style: AppText.button,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: AppSizes.primaryButtonHeight,
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        if (!mounted) {
                                          return const SizedBox.shrink();
                                        }
                                        final currentCardIndex = ref.watch(
                                          testInfoProvider.select(
                                            (v) => v.currentCardIndex,
                                          ),
                                        );
                                        return ElevatedButton.icon(
                                          onPressed:
                                              currentCardIndex <
                                                  questions.length - 1
                                              ? _nextCard
                                              : null,
                                          style: AppButtons.outlined.copyWith(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  AppColors.surfaceLight,
                                                ),
                                          ),
                                          label: const Text(
                                            'Next',
                                            style: AppText.button,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                            size: 20,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final isLoading = ref.watch(
                  testInfoProvider.select((v) => v.isLoading),
                );
                if (isLoading == false) return const SizedBox();
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.buttonBackground,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
