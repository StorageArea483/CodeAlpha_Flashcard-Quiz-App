import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_card_quiz/pages/test_info_page.dart';
import 'package:flash_card_quiz/providers/test_section_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class TestSection extends ConsumerStatefulWidget {
  final String testName;
  final int numberOfTests;

  const TestSection({
    super.key,
    required this.testName,
    required this.numberOfTests,
  });

  @override
  ConsumerState<TestSection> createState() => _TestSectionState();
}

class _TestSectionState extends ConsumerState<TestSection> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _numberOfOptionsController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  final List<TextEditingController> _questionControllers = [];

  @override
  void dispose() {
    _questionController.dispose();
    _numberOfOptionsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resetForm() {
    _questionController.clear();
    _numberOfOptionsController.clear();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers.clear();
    if (mounted) {
      ref.read(createTestProvider.notifier).setShowQuestionDescription(false);
      ref.read(createTestProvider.notifier).setShowOptionsInput(false);
      ref.read(createTestProvider.notifier).setNumberOfOptions(0);
    }
  }

  Future<bool> _saveQuestionToFirestore() async {
    try {
      // Set loading state to true
      if (mounted) {
        ref.read(createTestProvider.notifier).setLoadingState(true);
      }

      // Get Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Create a unique document ID
      final docId = firestore.collection('quizinfo').doc().id;

      // Prepare question data
      final questionData = {
        'testName': widget.testName,
        'question': _questionController.text.trim(),
        'numberOfOptions': _optionControllers.length,
        'options': _optionControllers
            .map((controller) => controller.text.trim())
            .toList(),
      };

      // Save to Firestore
      await firestore.collection('quizinfo').doc(docId).set(questionData);

      if (mounted) {
        ref.read(createTestProvider.notifier).setLoadingState(false);
      }
      return true;
    } catch (e) {
      if (mounted) {
        ref.read(createTestProvider.notifier).setLoadingState(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving data, please retry:'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        title: Text(widget.testName, style: AppText.appHeader),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Consumer(
                builder: (context, ref, child) {
                  if (!mounted) return const SizedBox.shrink();
                  // use to target the current question that is being set
                  final currentQuestionIndex = ref.watch(
                    createTestProvider.select(
                      (state) => state.currentQuestionIndex,
                    ),
                  );
                  // used to show the text field where user can set a question
                  if (!mounted) return const SizedBox.shrink();
                  final showQuestionDescription = ref.watch(
                    createTestProvider.select(
                      (state) => state.showQuestionDescription,
                    ),
                  );
                  // used to show the options input field for displaying options
                  if (!mounted) return const SizedBox.shrink();
                  final showOptionsInput = ref.watch(
                    createTestProvider.select(
                      (state) => state.showOptionsInput,
                    ),
                  );
                  // used for displaying options
                  if (!mounted) return const SizedBox.shrink();
                  final numberOfOptions = ref.watch(
                    createTestProvider.select((state) => state.numberOfOptions),
                  );
                  // used for loading state
                  if (!mounted) return const SizedBox.shrink();
                  final isLoading = ref.watch(
                    createTestProvider.select((state) => state.isLoading),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Test Counter Title
                      Center(
                        child: Text(
                          'Question: ${currentQuestionIndex + 1}/${widget.numberOfTests}',
                          style: AppText.formTitle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Step 1: Enter Question
                      const Text('Enter Question', style: AppText.fieldLabel),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _questionController,
                              decoration: AppTextFields.textFieldDecoration(
                                'Enter the question',
                              ),
                              style: AppText.base.copyWith(fontSize: 15),
                              enabled: !showQuestionDescription,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a question';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: showQuestionDescription
                                  ? AppColors.textLight
                                  : AppColors.buttonBackground,
                              borderRadius: BorderRadius.circular(
                                AppDecorations.primaryButtonRadius,
                              ),
                            ),
                            child: IconButton(
                              onPressed: showQuestionDescription
                                  ? null
                                  : () {
                                      if (_questionController.text
                                              .trim()
                                              .isNotEmpty &&
                                          mounted) {
                                        ref
                                            .read(createTestProvider.notifier)
                                            .setShowQuestionDescription(true);
                                        _questionControllers.add(
                                          _questionController,
                                        );
                                      }
                                    },
                              icon: const Icon(
                                Icons.check,
                                color: AppColors.buttonForeground,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Step 2: Enter Number of Options
                      if (showQuestionDescription) ...[
                        const Text(
                          'Number of Options',
                          style: AppText.fieldLabel,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _numberOfOptionsController,
                                decoration: AppTextFields.textFieldDecoration(
                                  'Enter number of options',
                                ),
                                style: AppText.base.copyWith(fontSize: 15),
                                keyboardType: TextInputType.number,
                                enabled: !showOptionsInput,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter number of options';
                                  }
                                  final number = int.tryParse(value);
                                  if (number == null || number < 2) {
                                    return 'Minimum 2 options required';
                                  }
                                  if (number > 4) {
                                    return 'Maximum 4 options allowed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: showOptionsInput
                                    ? AppColors.textLight
                                    : AppColors.buttonBackground,
                                borderRadius: BorderRadius.circular(
                                  AppDecorations.primaryButtonRadius,
                                ),
                              ),
                              child: IconButton(
                                onPressed: showOptionsInput
                                    ? null
                                    : () {
                                        final value = _numberOfOptionsController
                                            .text
                                            .trim();
                                        if (value.isNotEmpty && mounted) {
                                          final number = int.tryParse(value);
                                          if (number != null &&
                                              number >= 2 &&
                                              number <= 4) {
                                            ref
                                                .read(
                                                  createTestProvider.notifier,
                                                )
                                                .setNumberOfOptions(number);
                                            ref
                                                .read(
                                                  createTestProvider.notifier,
                                                )
                                                .setShowOptionsInput(true);
                                            // Create controllers for each option
                                            _optionControllers.clear();
                                            for (int i = 0; i < number; i++) {
                                              _optionControllers.add(
                                                TextEditingController(),
                                              );
                                            }
                                          }
                                        }
                                      },
                                icon: const Icon(
                                  Icons.check,
                                  color: AppColors.buttonForeground,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Step 3: Enter Options
                      if (showOptionsInput) ...[
                        const Text('Enter Options', style: AppText.fieldLabel),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: numberOfOptions,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: AppTextFields.textFieldDecoration(
                                  'Option ${index + 1}',
                                ),
                                style: AppText.base.copyWith(fontSize: 15),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter option ${index + 1}';
                                  }
                                  return null;
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: AppSizes.primaryButtonHeight,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Save question to Firestore
                                      final success =
                                          await _saveQuestionToFirestore();

                                      // Only proceed if save was successful
                                      if (!success) {
                                        _resetForm();
                                        return;
                                      }

                                      // Check if this is the last question
                                      if (currentQuestionIndex ==
                                          widget.numberOfTests - 1) {
                                        // All questions completed
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'All questions created!',
                                              ),
                                              backgroundColor:
                                                  AppColors.success,
                                            ),
                                          );
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TestInfoPage(
                                                    testName: widget.testName,
                                                    optionControllers:
                                                        _optionControllers,
                                                    questionControllers:
                                                        _questionControllers,
                                                  ),
                                            ),
                                          );
                                        }
                                      } else {
                                        // Move to next question
                                        if (mounted) {
                                          ref
                                              .read(createTestProvider.notifier)
                                              .setShowQuestionIndex(
                                                currentQuestionIndex + 1,
                                              );
                                          _resetForm();
                                        }
                                      }
                                    }
                                  },
                            style: AppButtons.primary,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.buttonForeground,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Question',
                                    style: AppText.submitButton,
                                  ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
