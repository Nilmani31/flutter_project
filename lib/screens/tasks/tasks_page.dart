import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/wedding_planner_provider.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Venue', 'Catering', 'Guests', 'Decoration'];

  void _showAddTaskDialog(BuildContext context, WeddingPlannerProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController();
    String priority = 'Medium';
    String category = 'Venue';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['High', 'Medium', 'Low'].map((p) => 
                  DropdownMenuItem(value: p, child: Text(p))
                ).toList(),
                onChanged: (value) => priority = value ?? 'Medium',
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: _categories.skip(1).map((c) => 
                  DropdownMenuItem(value: c, child: Text(c))
                ).toList(),
                onChanged: (value) => category = value ?? 'Venue',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final task = Task(
                  title: titleController.text,
                  subtitle: descriptionController.text,
                  dueDate: DateTime.tryParse(dueDateController.text) ?? DateTime.now(),
                  priority: priority,
                  category: category,
                  isCompleted: false,
                  createdAt: DateTime.now(),
                );
                await provider.addTask(task);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added successfully!')),
                  );
                }
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WeddingPlannerProvider provider, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.subtitle);
    final dueDateController = TextEditingController(text: task.dueDate.toString().split(' ')[0]);
    String priority = task.priority;
    String category = task.category;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                items: ['High', 'Medium', 'Low'].map((p) => 
                  DropdownMenuItem(value: p, child: Text(p))
                ).toList(),
                onChanged: (value) => priority = value ?? 'Medium',
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: _categories.skip(1).map((c) => 
                  DropdownMenuItem(value: c, child: Text(c))
                ).toList(),
                onChanged: (value) => category = value ?? 'Venue',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  subtitle: descriptionController.text,
                  dueDate: DateTime.tryParse(dueDateController.text) ?? task.dueDate,
                  priority: priority,
                  category: category,
                  updatedAt: DateTime.now(),
                );
                await provider.updateTask(updatedTask);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task updated successfully!')),
                  );
                }
              }
            },
            child: const Text('Update Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        final filteredTasks = _selectedCategory == 'All'
            ? provider.tasks
            : provider.tasks.where((t) => t.category == _selectedCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            elevation: 0,
          ),
          body: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks in this category',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: filteredTasks.map((task) {
                          return _TaskCard(
                            title: task.title,
                            subtitle: task.subtitle,
                            date: task.dueDate.toString().split(' ')[0],
                            priority: task.priority,
                            isCompleted: task.isCompleted,
                            onCheckboxChanged: (value) async {
                              final updatedTask = task.copyWith(isCompleted: value ?? false);
                              await provider.updateTask(updatedTask);
                            },
                            onEdit: () => _showEditTaskDialog(context, provider, task),
                            onDelete: () async {
                              await provider.deleteTask(task.id ?? '');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Task deleted!')),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String priority;
  final bool isCompleted;
  final Function(bool?)? onCheckboxChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.priority,
    required this.isCompleted,
    this.onCheckboxChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: onCheckboxChanged,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(date, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(priority),
                        backgroundColor: priority == 'High' ? Colors.red[100] : Colors.orange[100],
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: priority == 'High' ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
