import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/document_analysis.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered task subsets
  List<Task> get pendingTasks =>
      _tasks.where((t) => t.status == 'pending' && !t.isOverdue).toList();

  List<Task> get overdueTasks =>
      _tasks.where((t) => t.isOverdue).toList();

  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == 'completed').toList();

  List<Task> get dueTodayTasks =>
      _tasks.where((t) => t.isDueToday && t.status != 'completed').toList();

  List<Task> get urgentTasks => _tasks
      .where((t) => t.priority == 'urgent' && t.status != 'completed')
      .toList();

  // Metrics counts
  int get overdueCount => overdueTasks.length;
  int get dueTodayCount => dueTodayTasks.length;
  int get pendingCount => _tasks.where((t) => t.status != 'completed').length;
  int get completedCount => completedTasks.length;

  /// Top 3 prioritized actions for Daily AI Briefing
  List<Task> get dailyBriefingActions {
    final active = _tasks.where((t) => t.status != 'completed').toList();
    active.sort((a, b) {
      // 1. Overdue first
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // 2. Urgent priority next
      const priorityWeights = {'urgent': 3, 'high': 2, 'medium': 1, 'low': 0};
      final weightA = priorityWeights[a.priority] ?? 1;
      final weightB = priorityWeights[b.priority] ?? 1;
      if (weightA != weightB) return weightB.compareTo(weightA);

      // 3. Nearest deadline
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      return 0;
    });

    return active.take(3).toList();
  }

  /// AI Briefing text summary
  String get briefingSummary {
    if (overdueCount > 0) {
      return 'You have $overdueCount overdue task(s) that require immediate action, plus $pendingCount pending items.';
    } else if (dueTodayCount > 0) {
      return 'You have $dueTodayCount task(s) due today. Stay ahead by tackling your top priority items first.';
    } else if (pendingCount > 0) {
      return 'All tasks are on track. You have $pendingCount upcoming tasks scheduled this week.';
    } else {
      return 'No pending tasks! All your documents and action items are completed.';
    }
  }

  /// Load tasks for the current user
  Future<void> loadTasks({required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchTasks(userId: userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle completion of a task
  Future<void> toggleTask(Task task) async {
    final updated = await _taskService.toggleTaskCompletion(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
    }
  }

  /// Save confirmed suggested tasks from the Review screen
  Future<void> saveConfirmedTasks({
    required List<SuggestedTask> suggestedTasks,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final saved = await _taskService.saveConfirmedTasks(
        suggestedTasks: suggestedTasks,
        userId: userId,
      );
      _tasks.insertAll(0, saved);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }
}
