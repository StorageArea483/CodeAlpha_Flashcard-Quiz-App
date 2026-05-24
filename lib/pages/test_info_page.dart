import 'package:flutter/material.dart';

class TestInfoPage extends StatelessWidget {
  final String testName;
  final List<TextEditingController> optionControllers;
  final List<TextEditingController> questionControllers;
  const TestInfoPage({
    super.key,
    required this.testName,
    required this.optionControllers,
    required this.questionControllers,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
