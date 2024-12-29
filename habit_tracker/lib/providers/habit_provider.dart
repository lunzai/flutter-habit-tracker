import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/database_helper.dart';

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];
  bool isLoading = false;

  List<Habit> get habits => [..._habits];

  Future<void> loadHabits() async {
    isLoading = true;
    notifyListeners();
    
    try {
      _habits.clear();
      final habits = await DatabaseHelper.instance.readAllHabits();
      _habits.addAll(habits);
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await DatabaseHelper.instance.createHabit(habit);
      await loadHabits(); // Reload habits after adding
    } catch (e) {
      throw Exception('Failed to add habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await DatabaseHelper.instance.updateHabit(habit);
      await loadHabits(); // Reload habits after updating
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  Future<void> deleteHabit(int? id) async {
    if (id == null) return;
    
    try {
      await DatabaseHelper.instance.deleteHabit(id);
      await loadHabits(); // Reload habits after deletion
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }
} 