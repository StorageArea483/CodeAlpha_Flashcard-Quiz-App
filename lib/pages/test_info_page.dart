import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_card_quiz/providers/test_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class TestInfoPage extends ConsumerStatefulWidget {
  final String testName;

  const TestInfoPage({super.key, required this.testName});

  @override
  ConsumerState<TestInfoPage> createState() => _TestInfoPageState();
}

class _TestInfoPageState extends ConsumerState<TestInfoPage> {
  final _editFormKey = GlobalKey<FormState>();
  final _editQuestionController = TextEditingController();
  final List<TextEditingController> _editOptionControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuestionsFromFirestore();
    });
  }

  @override
  void dispose() {
    _editQuestionController.dispose();
    for (var controller in _editOptionControllers) {
      controller.dispose();
    }
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

      final questions = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'question': doc.data()['question'] as String,
          'options': List<String>.from(doc.data()['options'] as List),
          'numberOfOptions': doc.data()['numberOfOptions'] as int,
        };
      }).toList();

      if (mounted) {
        ref.read(testInfoProvider.notifier).setQuestions(questions);
        ref.read(testInfoProvider.notifier).setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        ref.read(testInfoProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching questions, please try again later'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion(String documentId) async {
    try {
      if (!mounted) return;
      ref.read(testInfoProvider.notifier).setLoading(true);

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('quizinfo').doc(documentId).delete();

      await _fetchQuestionsFromFirestore();
    } catch (e) {
      if (mounted) {
        ref.read(testInfoProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting question, please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateQuestion(String documentId) async {
    try {
      if (!mounted) return;
      ref.read(testInfoProvider.notifier).setLoading(true);

      final firestore = FirebaseFirestore.instance;

      if (_editOptionControllers.isEmpty) {
        throw Exception('No options provided');
      } else if (_editOptionControllers.length < 2) {
        throw Exception('Minimum 2 options required');
      } else if (_editOptionControllers.length > 4) {
        throw Exception('Maximum 4 options allowed');
      }
      // Prepare updated data
      final updatedData = {
        'question': _editQuestionController.text.trim(),
        'numberOfOptions': _editOptionControllers.length,
        'options': _editOptionControllers
            .map((controller) => controller.text.trim())
            .toList(),
      };

      // Update in Firestore
      await firestore
          .collection('quizinfo')
          .doc(documentId)
          .update(updatedData);

      // Refresh the list
      await _fetchQuestionsFromFirestore();
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

  void _showEditBottomSheet(Map<String, dynamic> question) {
    // Clear previous controllers
    for (var controller in _editOptionControllers) {
      controller.dispose();
    }
    _editOptionControllers.clear();

    // Pre-fill question
    _editQuestionController.text = question['question'] as String;

    // Pre-fill options
    final options = question['options'] as List<String>;
    for (var option in options) {
      final controller = TextEditingController(text: option);
      _editOptionControllers.add(controller);
    }

    final documentId = question['id'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: _editFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Title
                  Center(
                    child: Text(
                      'Edit Question',
                      style: AppText.formTitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Field
                  const Text('Question', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _editQuestionController,
                    decoration: AppTextFields.textFieldDecoration(
                      'Enter the question',
                    ),
                    style: AppText.base.copyWith(fontSize: 15),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Options Fields
                  const Text('Options', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _editOptionControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: _editOptionControllers[index],
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
                  const SizedBox(height: 24),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.primaryButtonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_editFormKey.currentState!.validate()) {
                          _updateQuestion(documentId);
                          Navigator.pop(context);
                        }
                      },
                      style: AppButtons.primary,
                      child: const Text('Update', style: AppText.submitButton),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                // App Logo
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/app-logo.png',
                  width: 100,
                  height: 100,
                ),
                // App Name
                const SizedBox(height: 10),
                Text(
                  'FlashCard Quiz',
                  style: AppText.welcomeTitle.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                // Questions List
                Consumer(
                  builder: (context, ref, child) {
                    if (!mounted) return const SizedBox.shrink();
                    final questions = ref.watch(
                      testInfoProvider.select((v) => v.questions),
                    );
                    return Expanded(
                      child: questions.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No questions found for this test',
                                    style: AppText.base.copyWith(
                                      color: AppColors.textLight,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                final options =
                                    question['options'] as List<String>;
                                final documentId = question['id'] as String;

                                return Consumer(
                                  builder: (context, ref, child) {
                                    if (!mounted) {
                                      return const SizedBox.shrink();
                                    }
                                    final isExpanded = ref.watch(
                                      questionExpandedProvider(index),
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: SimpleDecoration.card(),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (mounted) {
                                                ref
                                                        .read(
                                                          questionExpandedProvider(
                                                            index,
                                                          ).notifier,
                                                        )
                                                        .state =
                                                    !isExpanded;
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          question['question']
                                                              as String,
                                                          style: AppText.base
                                                              .copyWith(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                height: 1.4,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          _buildActionButton(
                                                            icon: Icons.edit,
                                                            color: AppColors
                                                                .primaryDark,
                                                            onPressed: () {
                                                              _showEditBottomSheet(
                                                                question,
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          _buildActionButton(
                                                            icon: Icons.delete,
                                                            color:
                                                                AppColors.error,
                                                            onPressed: () {
                                                              _deleteQuestion(
                                                                documentId,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      Icon(
                                                        isExpanded
                                                            ? Icons.expand_less
                                                            : Icons.expand_more,
                                                        color: AppColors
                                                            .primaryDark,
                                                        size: 28,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isExpanded)
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    16,
                                                    0,
                                                    16,
                                                    16,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 12),
                                                  ...options.asMap().entries.map((
                                                    entry,
                                                  ) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom: 8,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            12,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .surfaceLight,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .primaryDark
                                                              .withOpacity(0.2),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 24,
                                                            height: 24,
                                                            decoration:
                                                                const BoxDecoration(
                                                                  color: AppColors
                                                                      .primaryDark,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                            child: Center(
                                                              child: Text(
                                                                '${entry.key + 1}',
                                                                style: AppText.base.copyWith(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                            entry.value,
                                                            style: AppText.base
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .buttonBackground,
                                                                  height: 1.3,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    );
                  },
                ),
              ],
            ),
            // Loading overlay
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final isLoading = ref.watch(
                  testInfoProvider.select((v) => v.isLoading),
                );
                if (!isLoading) return const SizedBox.shrink();

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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
