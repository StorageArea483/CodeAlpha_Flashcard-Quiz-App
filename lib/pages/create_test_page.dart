import 'package:flash_card_quiz/pages/role_select_page.dart';
import 'package:flash_card_quiz/widgets/create_options_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../styles/styles.dart';

class CreateTestPage extends ConsumerStatefulWidget {
  const CreateTestPage({super.key});

  @override
  ConsumerState<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends ConsumerState<CreateTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _testNameController = TextEditingController();
  final _numberOfTestsController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  @override
  void dispose() {
    _testNameController.dispose();
    _numberOfTestsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
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
                  const SizedBox(height: 24),

                  // Start Time Field
                  const Text('Start Time', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _startTimeController,
                    decoration: AppTextFields.textFieldDecoration(
                      'Enter start time (e.g., 09:00)',
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter start time';
                      }
                      // Validate HH:mm format
                      final timeRegex = RegExp(
                        r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                      );
                      if (!timeRegex.hasMatch(value.trim())) {
                        return 'Invalid format. (e.g., 09:00 or 14:30)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // End Time Field
                  const Text('End Time', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _endTimeController,
                    decoration: AppTextFields.textFieldDecoration(
                      'Enter end time (e.g., 17:00)',
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter end time';
                      }
                      // Validate HH:mm format
                      final timeRegex = RegExp(
                        r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                      );
                      if (!timeRegex.hasMatch(value.trim())) {
                        return 'Invalid format. (e.g., 09:00 or 14:30)';
                      }

                      // Check if start time and end time are the same
                      if (_startTimeController.text.trim() == value.trim()) {
                        return 'End time must be different from start time';
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
                          final startTime = _startTimeController.text.trim();
                          final endTime = _endTimeController.text.trim();

                          // Parse times and validate end time is greater than start time
                          final startParts = startTime.split(':');
                          final endParts = endTime.split(':');

                          final startMinutes =
                              int.parse(startParts[0]) * 60 +
                              int.parse(startParts[1]);
                          final endMinutes =
                              int.parse(endParts[0]) * 60 +
                              int.parse(endParts[1]);

                          if (endMinutes <= startMinutes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'End time must be greater than start time',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => CreateOptionsSection(
                                  testName: testName,
                                  numberOfQuestions: numberOfQuestions,
                                  selectedTime: startTime,
                                  selectedEndTime: endTime,
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
