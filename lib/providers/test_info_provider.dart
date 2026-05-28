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
}

class CreateInfoState {
  final bool isLoading;
  final List<Map<String, dynamic>> questions;
  final TimeOfDay editSelectedTime;
  final TimeOfDay editSelectedEndTime;

  CreateInfoState({
    required this.isLoading,
    required this.questions,
    required this.editSelectedTime,
    required this.editSelectedEndTime,
  });

  CreateInfoState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? questions,
    TimeOfDay? editSelectedTime,
    TimeOfDay? editSelectedEndTime,
  }) {
    return CreateInfoState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      editSelectedTime: editSelectedTime ?? this.editSelectedTime,
      editSelectedEndTime: editSelectedEndTime ?? this.editSelectedEndTime,
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
