import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../services/database_helper.dart';

class ProgressProvider with ChangeNotifier {
  final Map<int, List<Progress>> _progressMap = {};
  bool isLoading = false;

  List<Progress> getProgressForHabit(int habitId) {
    return [...(_progressMap[habitId] ?? [])];
  }

  Future<void> loadProgress(int habitId) async {
    isLoading = true;
    notifyListeners();

    try {
      final progress = await DatabaseHelper.instance.readHabitProgress(habitId);
      _progressMap[habitId] = progress;
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProgress(Progress progress) async {
    try {
      final id = await DatabaseHelper.instance.createProgress(progress);
      final newProgress = Progress(
        id: id,
        habitId: progress.habitId,
        value: progress.value,
        note: progress.note,
        createdAt: progress.createdAt,
      );

      _progressMap[progress.habitId] = [
        newProgress,
        ...(_progressMap[progress.habitId] ?? []),
      ];
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add progress: $e');
    }
  }

  Future<void> deleteProgress(int habitId, int progressId) async {
    try {
      await DatabaseHelper.instance.deleteProgress(progressId);
      _progressMap[habitId]?.removeWhere((progress) => progress.id == progressId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete progress: $e');
    }
  }
} 