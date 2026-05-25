import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_card_quiz/pages/create_test_page.dart';
import 'package:flash_card_quiz/providers/role_select_provider.dart';
import 'package:flash_card_quiz/widgets/view_created_tests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class RoleSelectPage extends ConsumerStatefulWidget {
  const RoleSelectPage({super.key});

  @override
  ConsumerState<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends ConsumerState<RoleSelectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkQuizInfoCollection();
    });
  }

  Future<void> _checkQuizInfoCollection() async {
    try {
      if (mounted) {
        ref.read(isLoading.notifier).state = true;
      }

      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('quizinfo')
          .limit(1)
          .get();

      if (mounted) {
        ref.read(isNotEmpty.notifier).state = querySnapshot.docs.isNotEmpty;
        ref.read(isLoading.notifier).state = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred, please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(isLoading.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
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
                    // Feature Cards
                    _buildFeatureCard(
                      'Create Questions for Individuals',
                      Icons.create_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      'Test Individuals about their knowledge',
                      Icons.quiz_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      'Easy To Use for Daily Test Assessments',
                      Icons.assessment_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Create Test Button
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.primaryButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to create test page
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const CreateTestPage(),
                              ),
                            );
                          }
                        },
                        style: AppButtons.primary,
                        child: const Text(
                          'Create Test',
                          style: AppText.submitButton,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Take Test Button
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.primaryButtonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to take test page
                        },
                        style: AppButtons.outlined.copyWith(
                          side: WidgetStateProperty.all(
                            const BorderSide(
                              color: AppColors.primaryDark,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Take Test',
                          style: AppText.button.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        if (!mounted) return const SizedBox();
                        final isEmpty = ref.watch(isNotEmpty);
                        return isEmpty
                            ? const SizedBox()
                            : Column(
                                children: [
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: AppSizes.primaryButtonHeight,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewCreatedTests(),
                                          ),
                                        );
                                      },
                                      style: AppButtons.outlined.copyWith(
                                        side: WidgetStateProperty.all(
                                          const BorderSide(
                                            color: AppColors.primaryDark,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'View Created Tests',
                                        style: AppText.button.copyWith(
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Loading indicator at the bottom
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox();
                final loading = ref.watch(isLoading);
                if (!loading) return const SizedBox();
                return Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.buttonBackground,
                      ),
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

  Widget _buildFeatureCard(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: SimpleDecoration.card(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppText.fieldLabel.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
