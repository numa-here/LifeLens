import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/document_analysis.dart';
import '../models/scan_record.dart';
import '../providers/task_provider.dart';
import '../services/auth_service.dart';
import '../services/scan_history_service.dart';
import '../widgets/priority_badge.dart';

class ReviewScreen extends StatefulWidget {
  final DocumentAnalysisResult initialResult;
  final String? originalImageName;

  const ReviewScreen({
    super.key,
    required this.initialResult,
    this.originalImageName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late List<SuggestedTask> _tasks;
  late TextEditingController _extractedTextController;
  bool _isEditingOcr = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.initialResult.tasks);
    _extractedTextController =
        TextEditingController(text: widget.initialResult.rawExtractedText);
  }

  @override
  void dispose() {
    _extractedTextController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context, SuggestedTask task) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: task.deadline ?? now.add(const Duration(days: 3)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() {
        task.deadline = picked;
      });
    }
  }

  void _addNewTask() {
    setState(() {
      _tasks.add(
        SuggestedTask(
          id: const Uuid().v4(),
          title: 'New Action Item',
          deadline: DateTime.now().add(const Duration(days: 5)),
          priority: 'medium',
          sourceEvidence: 'Manually added during review',
        ),
      );
    });
  }

  Future<void> _confirmAndSave() async {
    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please keep at least one task to save.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = context.read<AuthService>().currentUser;
    final userId = user?.id ?? 'demo-user-123';

    try {
      // 1. Save tasks via TaskProvider
      await context.read<TaskProvider>().saveConfirmedTasks(
            suggestedTasks: _tasks,
            userId: userId,
          );

      // 2. Save scan history record
      final scanRecord = ScanRecord(
        id: const Uuid().v4(),
        userId: userId,
        detectedLanguage: widget.initialResult.detectedLanguage,
        summary: widget.initialResult.summary,
        extractedText: _extractedTextController.text,
        taskCount: _tasks.length,
        createdAt: DateTime.now(),
      );
      await ScanHistoryService().saveScan(scanRecord);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveSuccess),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save tasks: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final result = widget.initialResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviewTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Document & Language Metadata Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.detectedLanguage(result.detectedLanguage),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: result.isHandwritten
                              ? Colors.amber.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.isHandwritten
                                  ? Icons.draw_outlined
                                  : Icons.print_outlined,
                              size: 14,
                              color: result.isHandwritten
                                  ? Colors.amber.shade900
                                  : Colors.blue.shade900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.isHandwritten
                                  ? 'Handwritten Script'
                                  : 'Printed Document',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: result.isHandwritten
                                    ? Colors.amber.shade900
                                    : Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Warnings Banner (if any uncertain dates or items exist)
            if (result.warnings.isNotEmpty ||
                _tasks.any((t) => t.isDateUncertain)) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade900,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.uncertainDateWarning,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.warnings.isNotEmpty
                                ? result.warnings.first
                                : 'Please verify suggested dates against the source document before confirming.',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Extracted OCR Text Card (with Editable toggle)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(70),
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  l10n.ocrText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isEditingOcr ? Icons.check_circle : Icons.edit_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: _isEditingOcr ? 'Done Editing' : 'Edit OCR Text',
                      onPressed: () {
                        setState(() {
                          _isEditingOcr = !_isEditingOcr;
                        });
                      },
                    ),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _isEditingOcr
                        ? TextField(
                            controller: _extractedTextController,
                            maxLines: 8,
                            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              hintText: 'Edit extracted OCR text...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : SelectableText(
                            _extractedTextController.text,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Suggested Tasks Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.suggestedTasks(_tasks.length),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addNewTask,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tasks List
            ..._tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return _buildSuggestedTaskCard(task, index);
            }),

            const SizedBox(height: 32),

            // Confirm & Save Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _confirmAndSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.confirmAndSave,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedTaskCard(SuggestedTask task, int index) {
    final theme = Theme.of(context);
    final deadlineFormatted = task.deadline != null
        ? DateFormat('MMM d, yyyy').format(task.deadline!)
        : (task.rawDeadline ?? 'No date detected');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isDateUncertain
              ? Colors.amber.shade300
              : theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (val) {
                      task.title = val;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: 'Remove',
                  onPressed: () {
                    setState(() {
                      _tasks.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 16),

            // Priority Selector Row
            Row(
              children: [
                const Text(
                  'Priority: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                _buildPriorityDropdown(task),
              ],
            ),
            const SizedBox(height: 10),

            // Deadline Picker Row
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  deadlineFormatted,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: task.isDateUncertain ? FontWeight.bold : FontWeight.w500,
                    color: task.isDateUncertain ? Colors.amber.shade900 : null,
                  ),
                ),
                if (task.isDateUncertain) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Uncertain Date',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () => _selectDeadline(context, task),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Change Date'),
                ),
              ],
            ),

            // Source Evidence Box
            if (task.sourceEvidence != null && task.sourceEvidence!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source Evidence (Extracted):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.sourceEvidence!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Required documents if any
            if (task.requiredDocuments.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: task.requiredDocuments.map((doc) {
                  return Chip(
                    label: Text(doc, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(SuggestedTask task) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: task.priority,
        isDense: true,
        items: const [
          DropdownMenuItem(value: 'urgent', child: PriorityBadge(priority: 'urgent')),
          DropdownMenuItem(value: 'high', child: PriorityBadge(priority: 'high')),
          DropdownMenuItem(value: 'medium', child: PriorityBadge(priority: 'medium')),
          DropdownMenuItem(value: 'low', child: PriorityBadge(priority: 'low')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() {
              task.priority = val;
            });
          }
        },
      ),
    );
  }
}
