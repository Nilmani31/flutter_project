import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../../providers/user_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeddingPlannerProvider, UserProvider>(
      builder: (context, weddingProvider, userProvider, _) {
        int completedCount = weddingProvider.tasks.where((t) => t.isCompleted).length;
        int pendingCount = weddingProvider.tasks.where((t) => !t.isCompleted).length;
        int totalBudget = weddingProvider.budgets.fold<int>(0, (sum, b) => sum + b.amount.toInt());
        int guestCount = weddingProvider.guests.length;
        
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Wedding Planner', style: TextStyle(color: Colors.white)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, size: 50, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          'Welcome, ${userProvider.currentUser?.name ?? 'Guest'}!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards - Real Data
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.check_circle,
                            title: 'Completed',
                            value: completedCount.toString(),
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.schedule,
                            title: 'Pending',
                            value: pendingCount.toString(),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.people,
                            title: 'Guests',
                            value: guestCount.toString(),
                            color: const Color(0xFFD4486F),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OverviewCard(
                            icon: Icons.attach_money,
                            title: 'Budget',
                            value: '\$${totalBudget}',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    
                    // Upcoming Tasks
                    Text(
                      'Upcoming Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (weddingProvider.tasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No tasks yet. Go to Tasks tab to add some!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...weddingProvider.tasks.take(3).map((task) => _TaskListItem(
                        title: task.title,
                        date: task.dueDate.toString().split(' ')[0],
                        priority: task.priority,
                      )).toList(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Overview Card Widget
class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task List Item Widget
class _TaskListItem extends StatelessWidget {
  final String title;
  final String date;
  final String priority;

  const _TaskListItem({
    required this.title,
    required this.date,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        size: 12,
        color: priority == 'High' ? Colors.red : Colors.orange,
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(priority, style: const TextStyle(fontSize: 12)),
      onTap: () {},
    );
  }
}
