import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/document_analysis.dart';
import 'supabase_service.dart';

class TaskService {
  final SupabaseService _supabaseService = SupabaseService();

  // In-memory mock task repository for frontend testing and demo
  final List<Task> _mockTasks = [
    Task(
      id: 'task-1',
      userId: 'demo-user-123',
      title: 'Pay Electricity & Water Assessment Fee',
      description: 'Account ID: 8842-TX-2026. Clear balance before due date.',
      deadline: DateTime.now().add(const Duration(days: 3)),
      priority: 'urgent',
      status: 'pending',
      sourceEvidence: 'Notice dated 12 Oct: Pending assessment charges must be paid before due date.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: 'task-2',
      userId: 'demo-user-123',
      title: 'Submit Property Tax Declaration Form',
      description: 'Attach copy of previous receipt #4029 and latest bill.',
      deadline: DateTime.now().add(const Duration(days: 7)),
      priority: 'high',
      status: 'pending',
      sourceEvidence: 'Section 4: Submit physical declaration form with latest bill photocopy.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: 'task-3',
      userId: 'demo-user-123',
      title: 'Doctor Follow-up & Lab Report Verification',
      description: 'Handwritten prescription notes checkup on Friday morning.',
      deadline: DateTime.now().subtract(const Duration(days: 1)), // Overdue
      priority: 'medium',
      status: 'pending',
      sourceEvidence: 'Dr. Rao clinic note: Review blood panel after 5 days.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Task(
      id: 'task-4',
      userId: 'demo-user-123',
      title: 'Renew Annual Health Insurance Policy',
      description: 'Submitted premium receipt and downloaded digital card.',
      deadline: DateTime.now().subtract(const Duration(days: 4)),
      priority: 'low',
      status: 'completed',
      sourceEvidence: 'Policy renewal reminder email from Star Health.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// Fetch user tasks from Supabase or local mock
  Future<List<Task>> fetchTasks({required String userId}) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return List.from(_mockTasks);
    }

    // ==========================================
    // OMEMA INTEGRATION POINT: Supabase 'tasks' table
    // ==========================================
    try {
      final response = await _supabaseService.client!
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('deadline', ascending: true);

      return (response as List<dynamic>)
          .map((data) => Task.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[TaskService] Supabase fetch failed: $e. Using mock fallback.');
      return List.from(_mockTasks);
    }
  }

  /// Save multiple confirmed tasks from the AI Review Screen
  Future<List<Task>> saveConfirmedTasks({
    required List<SuggestedTask> suggestedTasks,
    required String userId,
  }) async {
    final newTasks = suggestedTasks.map((s) {
      return Task(
        id: const Uuid().v4(),
        userId: userId,
        title: s.title,
        description: s.description,
        deadline: s.deadline,
        priority: s.priority,
        status: 'pending',
        sourceEvidence: s.sourceEvidence,
        isConfirmed: true,
        createdAt: DateTime.now(),
      );
    }).toList();

    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      _mockTasks.insertAll(0, newTasks);
      return newTasks;
    }

    // ==========================================
    // OMEMA INTEGRATION POINT: Batch insert into 'tasks'
    // ==========================================
    try {
      final payload = newTasks.map((t) => t.toMap()).toList();
      await _supabaseService.client!.from('tasks').insert(payload);
      return newTasks;
    } catch (e) {
      debugPrint('[TaskService] Supabase insert failed: $e. Saving to local mock.');
      _mockTasks.insertAll(0, newTasks);
      return newTasks;
    }
  }

  /// Create a single task
  Future<Task> createTask(Task task) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      _mockTasks.insert(0, task);
      return task;
    }

    // OMEMA INTEGRATION POINT: Supabase insert
    try {
      await _supabaseService.client!.from('tasks').insert(task.toMap());
      return task;
    } catch (e) {
      debugPrint('[TaskService] Create task failed: $e');
      _mockTasks.insert(0, task);
      return task;
    }
  }

  /// Toggle task completion status
  Future<Task> toggleTaskCompletion(Task task) async {
    final updatedStatus = task.status == 'completed' ? 'pending' : 'completed';
    final updatedTask = task.copyWith(
      status: updatedStatus,
      updatedAt: DateTime.now(),
    );

    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      final index = _mockTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _mockTasks[index] = updatedTask;
      }
      return updatedTask;
    }

    // OMEMA INTEGRATION POINT: Supabase update status
    try {
      await _supabaseService.client!
          .from('tasks')
          .update({'status': updatedStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', task.id);
      return updatedTask;
    } catch (e) {
      debugPrint('[TaskService] Toggle status failed: $e');
      return updatedTask;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    if (_supabaseService.isMockMode || _supabaseService.client == null) {
      _mockTasks.removeWhere((t) => t.id == taskId);
      return true;
    }

    // OMEMA INTEGRATION POINT: Supabase delete
    try {
      await _supabaseService.client!.from('tasks').delete().eq('id', taskId);
      return true;
    } catch (e) {
      debugPrint('[TaskService] Delete failed: $e');
      _mockTasks.removeWhere((t) => t.id == taskId);
      return true;
    }
  }
}
