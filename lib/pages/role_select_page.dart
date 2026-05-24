import 'package:flash_card_quiz/pages/create_test_page.dart';
import 'package:flutter/material.dart';
import '../styles/styles.dart';

class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
              ],
            ),
          ),
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
