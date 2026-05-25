import 'package:flash_card_quiz/pages/role_select_page.dart';
import 'package:flash_card_quiz/widgets/create_options_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/styles.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _testNameController = TextEditingController();
  final _numberOfTestsController = TextEditingController();

  @override
  void dispose() {
    _testNameController.dispose();
    _numberOfTestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Logo
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/app-logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  // Page Title
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Create Test',
                      style: AppText.welcomeTitle.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Test Name Field
                  const Text('Test Name', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _testNameController,
                    decoration: AppTextFields.textFieldDecoration(
                      'Enter test name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a test name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Number of Tests Field
                  const Text('Questions Number', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _numberOfTestsController,
                    decoration: AppTextFields.textFieldDecoration(
                      'Enter number of questions',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter number of questions';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Please enter a valid number greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Proceed Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.primaryButtonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle proceed action
                          final testName = _testNameController.text.trim();
                          final numberOfQuestions = int.parse(
                            _numberOfTestsController.text,
                          );
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => CreateOptionsSection(
                                  testName: testName,
                                  numberOfQuestions: numberOfQuestions,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: AppButtons.primary,
                      child: const Text('Proceed', style: AppText.submitButton),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.primaryButtonHeight,
                    child: OutlinedButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const RoleSelectPage(),
                            ),
                          );
                        }
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
                        'Back',
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
      ),
    );
  }
}
