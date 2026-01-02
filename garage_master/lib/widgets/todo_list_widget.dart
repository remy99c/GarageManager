import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

class TodoListWidget extends StatelessWidget {
  final List<ChecklistItem> items;
  final bool isEditing;
  final Function(int, bool)? onItemToggle;
  final Function(List<ChecklistItem>)? onItemsChanged;

  const TodoListWidget({
    super.key,
    required this.items,
    this.isEditing = false,
    this.onItemToggle,
    this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textMuted.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist, color: AppTheme.accentOrange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'To-Do List',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.accentOrange,
                  iconSize: 22,
                  onPressed: () => _showAddItemDialog(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No tasks added yet',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => onItemToggle?.call(index, !item.isDone),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item.isDone
                              ? AppTheme.successGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.isDone
                                ? AppTheme.successGreen
                                : AppTheme.textMuted,
                            width: 2,
                          ),
                        ),
                        child: item.isDone
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.task,
                        style: TextStyle(
                          color: item.isDone
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          decoration:
                              item.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.errorRed,
                        iconSize: 20,
                        onPressed: () {
                          final newItems = List<ChecklistItem>.from(items);
                          newItems.removeAt(index);
                          onItemsChanged?.call(newItems);
                        },
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter task description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newItems = List<ChecklistItem>.from(items);
                newItems.add(ChecklistItem(task: controller.text));
                onItemsChanged?.call(newItems);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
