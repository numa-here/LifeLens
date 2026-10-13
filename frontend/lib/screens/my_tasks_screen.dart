import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'upload_screen.dart';

class MyTasksScreen extends StatefulWidget {
  final String initialFilter;

  const MyTasksScreen({super.key, this.initialFilter = 'all'});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  late String _activeFilter;
  String _priorityFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(TaskProvider provider) {
    List<Task> list;
    switch (_activeFilter) {
      case 'pending':
        list = provider.pendingTasks;
        break;
      case 'dueToday':
        list = provider.dueTodayTasks;
        break;
      case 'overdue':
        list = provider.overdueTasks;
        break;
      case 'completed':
        list = provider.completedTasks;
        break;
      case 'all':
      default:
        list = provider.tasks;
        break;
    }

    if (_priorityFilter != 'all') {
      list = list.where((t) => t.priority == _priorityFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(q);
        final descMatch = t.description?.toLowerCase().contains(q) ?? false;
        final evidenceMatch = t.sourceEvidence?.toLowerCase().contains(q) ?? false;
        return titleMatch || descMatch || evidenceMatch;
      }).toList();
    }

    return list;
  }

  Future<void> _deleteTask(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to remove "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final filteredTasks = _getFilteredTasks(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTasks),
        centerTitle: false,
        actions: [
          // Priority filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter by Priority',
            onSelected: (val) {
              setState(() => _priorityFilter = val);
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'all',
                child: Text('All Priorities ${_priorityFilter == 'all' ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'urgent',
                child: Text('Urgent ${_priorityFilter == 'urgent' ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'high',
                child: Text('High ${_priorityFilter == 'high' ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'medium',
                child: Text('Medium ${_priorityFilter == 'medium' ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'low',
                child: Text('Low ${_priorityFilter == 'low' ? '✓' : ''}'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks, deadlines or evidence...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(60),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', '${l10n.filterAll} (${taskProvider.tasks.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('pending', '${l10n.pendingTasks} (${taskProvider.pendingCount})'),
                const SizedBox(width: 8),
                _buildFilterChip('dueToday', '${l10n.dueTodayTasks} (${taskProvider.dueTodayCount})'),
                const SizedBox(width: 8),
                _buildFilterChip('overdue', '${l10n.overdueTasks} (${taskProvider.overdueCount})'),
                const SizedBox(width: 8),
                _buildFilterChip('completed', '${l10n.completedTasks} (${taskProvider.completedCount})'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Task List or Empty State
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Tasks Found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No tasks match "$_searchQuery".'
                                : 'No items match the current filter.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UploadScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                            label: Text(l10n.analyzeDocumentCTA),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 6, bottom: 80),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: (val) {
                          taskProvider.toggleTask(task);
                        },
                        onDelete: () => _deleteTask(context, task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadScreen()),
          );
        },
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan Document'),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _activeFilter == filterKey;
    final theme = Theme.of(context);

    Color? selectedColor;
    if (filterKey == 'overdue') selectedColor = Colors.red.shade100;
    if (filterKey == 'dueToday') selectedColor = Colors.orange.shade100;
    if (filterKey == 'completed') selectedColor = Colors.green.shade100;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: selectedColor ?? theme.colorScheme.primaryContainer,
      onSelected: (_) {
        setState(() => _activeFilter = filterKey);
      },
    );
  }
}
