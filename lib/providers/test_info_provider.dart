import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class TestInfoNotifier extends StateNotifier<CreateInfoState> {
  TestInfoNotifier()
    : super(
        CreateInfoState(
          isLoading: false,
          questions: [],
          editSelectedTime: const TimeOfDay(hour: 0, minute: 0),
          editSelectedEndTime: const TimeOfDay(hour: 0, minute: 0),
          remainingSeconds: 0,
          currentCardIndex: 0,
          showAnswer: false,
        ),
      );

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setQuestions(List<Map<String, dynamic>> questions) {
    state = state.copyWith(questions: questions);
  }

  void setSelectedTime(TimeOfDay day) {
    state = state.copyWith(editSelectedTime: day);
  }

  void setSelectedEndTime(TimeOfDay day) {
    state = state.copyWith(editSelectedEndTime: day);
  }

  void setRemainingSeconds(int value) {
    state = state.copyWith(remainingSeconds: value);
  }

  void setCurrentCardIndex(int index) {
    state = state.copyWith(currentCardIndex: index);
  }

  void setShowAnswer(bool show) {
    state = state.copyWith(showAnswer: show);
  }
}

class CreateInfoState {
  final bool isLoading;
  final List<Map<String, dynamic>> questions;
  final TimeOfDay editSelectedTime;
  final TimeOfDay editSelectedEndTime;
  final int remainingSeconds;
  final int currentCardIndex;
  final bool showAnswer;

  CreateInfoState({
    required this.isLoading,
    required this.questions,
    required this.editSelectedTime,
    required this.editSelectedEndTime,
    required this.remainingSeconds,
    required this.currentCardIndex,
    required this.showAnswer,
  });

  CreateInfoState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? questions,
    TimeOfDay? editSelectedTime,
    TimeOfDay? editSelectedEndTime,
    int? remainingSeconds,
    int? currentCardIndex,
    bool? showAnswer,
  }) {
    return CreateInfoState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      editSelectedTime: editSelectedTime ?? this.editSelectedTime,
      editSelectedEndTime: editSelectedEndTime ?? this.editSelectedEndTime,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      showAnswer: showAnswer ?? this.showAnswer,
    );
  }
}

final testInfoProvider =
    StateNotifierProvider<TestInfoNotifier, CreateInfoState>((ref) {
      return TestInfoNotifier();
    });

// Family provider to track each question's expanded state independently
final questionExpandedProvider = StateProvider.family.autoDispose<bool, int>(
  (ref, questionIndex) => false,
);
