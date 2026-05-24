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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuestionsFromFirestore();
    });
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
      body: Consumer(
        builder: (context, ref, child) {
          final isLoading = ref.watch(
            testInfoProvider.select((v) => v.isLoading),
          );
          final questions = ref.watch(
            testInfoProvider.select((v) => v.questions),
          );

          return isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonBackground,
                  ),
                )
              : questions.isEmpty
              ? Center(
                  child: Text(
                    'No questions found for this test',
                    style: AppText.base.copyWith(
                      color: AppColors.textLight,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final options = question['options'] as List<String>;

                    return Consumer(
                      builder: (context, ref, child) {
                        final isExpanded = ref.watch(
                          questionExpandedProvider(index),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  question['question'] as String,
                                  style: AppText.base.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: AppColors.primaryDark,
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: AppColors.error,
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 24,
                                      ),
                                      color: AppColors.primaryDark,
                                      onPressed: () {
                                        ref
                                                .read(
                                                  questionExpandedProvider(
                                                    index,
                                                  ).notifier,
                                                )
                                                .state =
                                            !isExpanded;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Options:',
                                        style: AppText.base.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...options.asMap().entries.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.key + 1}. ',
                                                style: AppText.base.copyWith(
                                                  fontSize: 13,
                                                  color: AppColors.textLight,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: AppText.base.copyWith(
                                                    fontSize: 13,
                                                    color: AppColors.textLight,
                                                  ),
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
                );
        },
      ),
    );
  }
}
