import 'package:flash_card_quiz/pages/role_select_page.dart';
import 'package:flash_card_quiz/providers/create_test_provider.dart';
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

  @override
  void dispose() {
    _testNameController.dispose();
    _numberOfTestsController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryDark,
              secondary: AppColors.primaryDark,
              onSecondary: Colors.white,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppColors.primaryDark,
              hourMinuteColor: AppColors.background,
              dayPeriodTextColor: AppColors.primaryDark,
              dayPeriodColor: AppColors.background,
              dayPeriodBorderSide: BorderSide(color: AppColors.primaryDark),
              dialHandColor: AppColors.primaryDark,
              dialBackgroundColor: AppColors.background,
              dialTextColor: AppColors.primaryDark,
              entryModeIconColor: AppColors.primaryDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      ref.read(createTestProvider.notifier).state = picked;
    }
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

                  // Test Time Field
                  const Text('Test Time', style: AppText.fieldLabel),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      if (!mounted) return const SizedBox.shrink();
                      final selectedTime = ref.watch(createTestProvider);
                      return InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(
                          AppDecorations.primaryButtonRadius,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(
                              AppDecorations.primaryButtonRadius,
                            ),
                            border: Border.all(
                              color: AppColors.primaryDark.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedTime != null
                                    ? selectedTime.format(context)
                                    : 'Select test time',
                                style: AppText.base.copyWith(
                                  fontSize: 15,
                                  color: selectedTime != null
                                      ? AppColors.buttonBackground
                                      : AppColors.textLight,
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                color: AppColors.primaryDark,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
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
                          if (!mounted) return;
                          final selectedTime = ref.read(createTestProvider);
                          if (selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a test time'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
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
                                  selectedTime: selectedTime,
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
