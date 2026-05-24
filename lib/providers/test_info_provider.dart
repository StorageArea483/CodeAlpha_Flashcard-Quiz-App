import 'package:flutter_riverpod/legacy.dart';

class TestInfoNotifier extends StateNotifier<CreateInfoState> {
  TestInfoNotifier() : super(CreateInfoState(isLoading: false, questions: []));

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setQuestions(List<Map<String, dynamic>> questions) {
    state = state.copyWith(questions: questions);
  }
}

class CreateInfoState {
  final bool isLoading;
  final List<Map<String, dynamic>> questions;

  CreateInfoState({required this.isLoading, required this.questions});

  CreateInfoState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? questions,
  }) {
    return CreateInfoState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
    );
  }
}

final testInfoProvider =
    StateNotifierProvider<TestInfoNotifier, CreateInfoState>((ref) {
      return TestInfoNotifier();
    });
