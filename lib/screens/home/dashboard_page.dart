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
        
        return Stack(
          children: [
            // Background gradient matching login page
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                        // Glassmorphism
                        backgroundBlendMode: BlendMode.overlay,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glowing animated avatar
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.05),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFD4AF37).withOpacity(0.25),
                                          blurRadius: 32,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/logo.png',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            if (weddingProvider.weddingProfile != null && weddingProvider.weddingProfile!.weddingName.isNotEmpty)
                              Column(
                                children: [
                                  Text(
                                    weddingProvider.weddingProfile!.weddingName,
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: const Color.fromARGB(255, 61, 46, 66),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  if (weddingProvider.weddingProfile!.weddingDate != null)
                                    Builder(
                                      builder: (context) {
                                        final now = DateTime.now();
                                        final weddingDate = weddingProvider.weddingProfile!.weddingDate;
                                        final days = weddingDate.difference(now).inDays;
                                        String text;
                                        if (days > 0) {
                                          text = '$days days to your wedding';
                                        } else if (days == 0) {
                                          text = 'Today is your wedding!';
                                        } else {
                                          text = 'Your wedding was ${-days} days ago';
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 103, 27, 52).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(255, 103, 27, 52).withOpacity(0.08),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            text,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: const Color.fromARGB(255, 103, 27, 52),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated Modern Overview Cards
                        Row(
                          children: [
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                                child: _ModernOverviewCard(
                                  icon: Icons.check_circle,
                                  title: 'Completed',
                                  value: completedCount.toString(),
                                  color: const Color.fromARGB(255, 61, 46, 66),
                                  background: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                                child: _ModernOverviewCard(
                                  icon: Icons.schedule,
                                  title: 'Pending',
                                  value: pendingCount.toString(),
                                  color: const Color.fromARGB(255, 103, 27, 52),
                                  background: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 1100),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                                child: _ModernOverviewCard(
                                  icon: Icons.people,
                                  title: 'Guests',
                                  value: guestCount.toString(),
                                  color: const Color.fromARGB(255, 103, 27, 52),
                                  background: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 1300),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) => Transform.scale(
                                  scale: scale,
                                  child: child,
                                ),
                                child: _ModernOverviewCard(
                                  icon: Icons.attach_money,
                                  title: 'Budget',
                                  value: '\$${totalBudget}',
                                  color: const Color.fromARGB(255, 61, 46, 66),
                                  background: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Stylish Section Header
                        Row(
                          children: [
                            const Icon(Icons.event_note, color: Color.fromARGB(255, 61, 46, 66)),
                            const SizedBox(width: 8),
                            Text(
                              'Upcoming Tasks',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 103, 27, 52),
                                  ),
                            ),
                          ],
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
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: weddingProvider.tasks.take(5).length,
                              separatorBuilder: (context, i) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final task = weddingProvider.tasks[i];
                                return _ModernTaskListItem(
                                  title: task.title,
                                  date: task.dueDate.toString().split(' ')[0],
                                  priority: task.priority,
                                  width: 220,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Action Button
          ],
        );
      },
    );
  }
}

// Overview Card Widget

// Modern Overview Card Widget
class _ModernOverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color? background;

  const _ModernOverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// Task List Item Widget

// Modern Task List Item Widget

// Creative Modern Task List Item Widget
class _ModernTaskListItem extends StatelessWidget {
  final String title;
  final String date;
  final String priority;
  final double width;

  const _ModernTaskListItem({
    required this.title,
    required this.date,
    required this.priority,
    this.width = 220,
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
    return Container(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white.withOpacity(0.92),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: getPriorityColor().withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.flag,
                      color: getPriorityColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 15, color: Color(0xFFB76E79)),
                  const SizedBox(width: 4),
                  Text(date, style: const TextStyle(color: Color(0xFF7A5C5E), fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: getPriorityColor().withOpacity(0.13),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: getPriorityColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
