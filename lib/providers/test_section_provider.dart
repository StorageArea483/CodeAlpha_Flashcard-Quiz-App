import 'package:flutter_riverpod/legacy.dart';

class TestSectionNotifier extends StateNotifier<CreateTestState> {
  TestSectionNotifier()
    : super(
        CreateTestState(
          currentQuestionIndex: 0,
          showQuestionDescription: false,
          showOptionsInput: false,
          isLoading: false,
          numberOfOptions: 0,
        ),
      );

  void setShowQuestionIndex(int value) {
    state = state.copyWith(currentQuestionIndex: value);
  }

  void setShowQuestionDescription(bool value) {
    state = state.copyWith(showQuestionDescription: value);
  }

  void setShowOptionsInput(bool value) {
    state = state.copyWith(showOptionsInput: value);
  }

  void setLoadingState(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void setNumberOfOptions(int value) {
    state = state.copyWith(numberOfOptions: value);
  }
}

class CreateTestState {
  final int currentQuestionIndex;
  final bool showQuestionDescription;
  final bool showOptionsInput;
  final bool isLoading;
  final int numberOfOptions;

  CreateTestState({
    required this.currentQuestionIndex,
    required this.showQuestionDescription,
    required this.showOptionsInput,
    required this.isLoading,
    required this.numberOfOptions,
  });

  CreateTestState copyWith({
    int? currentQuestionIndex,
    bool? showQuestionDescription,
    bool? showOptionsInput,
    bool? isLoading,
    int? numberOfOptions,
  }) {
    return CreateTestState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      showQuestionDescription:
          showQuestionDescription ?? this.showQuestionDescription,
      showOptionsInput: showOptionsInput ?? this.showOptionsInput,
      isLoading: isLoading ?? this.isLoading,
      numberOfOptions: numberOfOptions ?? this.numberOfOptions,
    );
  }
}

final createTestProvider =
    StateNotifierProvider.autoDispose<TestSectionNotifier, CreateTestState>((
      ref,
    ) {
      return TestSectionNotifier();
    });
