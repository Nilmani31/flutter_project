import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/wedding_planner_provider.dart';

import 'dart:ui';

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
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(220, 222, 205, 225),
                    Color.fromARGB(220, 234, 205, 215),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFB76E79)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(7),
                          child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Text('Add New Task',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF3D2E42), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date (YYYY-MM-DD)',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: priority,
                      items: ['High', 'Medium', 'Low'].map((p) =>
                        DropdownMenuItem(value: p, child: Text(p))
                      ).toList(),
                      onChanged: (value) => priority = value ?? 'Medium',
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: _categories.skip(1).map((c) =>
                        DropdownMenuItem(value: c, child: Text(c))
                      ).toList(),
                      onChanged: (value) => category = value ?? 'Venue',
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7A5C5E),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            elevation: 0,
                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
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
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(220, 222, 205, 225),
                    Color.fromARGB(220, 234, 205, 215),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFB76E79)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(7),
                          child: const Icon(Icons.edit, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Text('Edit Task',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF3D2E42), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: dueDateController,
                      decoration: InputDecoration(
                        labelText: 'Due Date (YYYY-MM-DD)',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: priority,
                      items: ['High', 'Medium', 'Low'].map((p) =>
                        DropdownMenuItem(value: p, child: Text(p))
                      ).toList(),
                      onChanged: (value) => priority = value ?? 'Medium',
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: _categories.skip(1).map((c) =>
                        DropdownMenuItem(value: c, child: Text(c))
                      ).toList(),
                      onChanged: (value) => category = value ?? 'Venue',
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.85),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF7A5C5E),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            elevation: 0,
                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
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

        return Stack(
          children: [
            // Background gradient matching dashboard
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 222, 205, 225),
                      const Color.fromARGB(255, 234, 205, 215),
                    ],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: const Color.fromARGB(255, 61, 46, 66),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  selectedColor: const Color.fromARGB(255, 103, 27, 52).withOpacity(0.15),
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == category
                                        ? const Color.fromARGB(255, 103, 27, 52)
                                        : const Color.fromARGB(255, 61, 46, 66),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No tasks in this category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final task = filteredTasks[i];
                          return _ModernTaskCard(
                            title: task.title,
                            subtitle: task.subtitle,
                            date: task.dueDate.toString().split(' ')[0],
                            priority: task.priority,
                            isCompleted: task.isCompleted,
                            onCheckboxChanged: (value) async {
                              final updatedTask = task.copyWith(isCompleted: value ?? false);
                              await provider.updateTask(updatedTask);
                            },
                            onEdit: null,
                            onDelete: null,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                ),
                                backgroundColor: Colors.white,
                                builder: (ctx) => ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                                  color: const Color(0xFFB76E79),
                                                  size: 28,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                          color: const Color(0xFF3D2E42), fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (task.subtitle.isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              Text(
                                                task.subtitle,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Colors.grey[700],
                                                    ),
                                              ),
                                            ],
                                            const SizedBox(height: 18),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today, size: 18, color: Color(0xFFB76E79)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  task.dueDate.toString().split(' ')[0],
                                                  style: const TextStyle(color: Color(0xFF7A5C5E), fontSize: 15, fontWeight: FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.pinkAccent.withOpacity(0.16),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.flag,
                                                        size: 16,
                                                        color: Colors.pinkAccent,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        task.priority,
                                                        style: const TextStyle(
                                                          color: Colors.pinkAccent,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:const Color(0xFF3D2E42), // Unified luxury purple
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                                    elevation: 0,
                                                  ),
                                                  icon: const Icon(Icons.edit, size: 20),
                                                  label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    _showEditTaskDialog(context, provider, task);
                                                  },
                                                ),
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF3D2E42), // Unified luxury purple
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                                    elevation: 0,
                                                  ),
                                                  icon: const Icon(Icons.delete, size: 20),
                                                  label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                                                  onPressed: () async {
                                                    await provider.deleteTask(task.id ?? '');
                                                    Navigator.pop(ctx);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Task deleted!')),
                                                      );
                                                    }
                                                  },
                                                ),
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF3D2E42), // Unified luxury purple
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                                    elevation: 0,
                                                  ),
                                                  icon: const Icon(Icons.check, size: 20),
                                                  label: Text(task.isCompleted ? 'Undone' : 'Done', style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  onPressed: () async {
                                                    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
                                                    await provider.updateTask(updatedTask);
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _showAddTaskDialog(context, provider),
                backgroundColor: const Color.fromARGB(255, 53, 30, 57),
                child: const Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 76, 76, 75), // Gold color
                  size: 32,
                  shadows: [
                    Shadow(
                      color: Color(0xFFB76E79),
                      blurRadius: 6,
                    ),
                  ],
                ),
                elevation: 6,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Modern Task Card Widget (dashboard style)
class _ModernTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String priority;
  final bool isCompleted;
  final Function(bool?)? onCheckboxChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const _ModernTaskCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.priority,
    required this.isCompleted,
    this.onCheckboxChanged,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  Color getPriorityColor() {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 1.2,
          ),
          // Glassmorphism effect
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: onCheckboxChanged,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        activeColor: const Color(0xFFB76E79),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF3D2E42),
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getPriorityColor().withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 16,
                              color: getPriorityColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              priority,
                              style: TextStyle(
                                color: getPriorityColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFFB76E79)),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: const TextStyle(color: Color(0xFF7A5C5E), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      // Edit/Delete moved to popup
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
