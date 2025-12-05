import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/wedding_planner_provider.dart';
import 'screens/login_screen.dart';
import 'screens/wedding_details_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeddingPlannerApp());
}

class WeddingPlannerApp extends StatelessWidget {
  const WeddingPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeddingPlannerProvider(),
      child: MaterialApp(
        title: 'Wedding Planner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD4486F),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }
            
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TasksPage(),
    const BudgetPage(),
    const GuestsPage(),
    const MorePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkWeddingProfile();
  }

  Future<void> _checkWeddingProfile() async {
    final provider = Provider.of<WeddingPlannerProvider>(context, listen: false);
    await provider.checkWeddingProfile();
    
    // If no wedding profile, navigate to form
    if (!provider.hasWeddingProfile && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const WeddingDetailsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Guests',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

// Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'Just 45 Days Away!',
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
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _OverviewCard(
                        icon: Icons.check_circle,
                        title: 'Completed',
                        value: '28',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OverviewCard(
                        icon: Icons.schedule,
                        title: 'Pending',
                        value: '12',
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
                        value: '150',
                        color: const Color(0xFFD4486F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OverviewCard(
                        icon: Icons.attach_money,
                        title: 'Budget Used',
                        value: '65%',
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
                _TaskListItem(
                  title: 'Finalize venue booking',
                  date: 'Dec 5, 2024',
                  priority: 'High',
                ),
                _TaskListItem(
                  title: 'Confirm catering menu',
                  date: 'Dec 8, 2024',
                  priority: 'High',
                ),
                _TaskListItem(
                  title: 'Send invitation reminders',
                  date: 'Dec 12, 2024',
                  priority: 'Medium',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Tasks Page
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Venue', 'Catering', 'Guests', 'Decoration'];

  @override
  Widget build(BuildContext context) {
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _TaskCard(
                  title: 'Book the venue',
                  subtitle: 'Reserve the main hall and outdoor area',
                  date: 'Dec 5, 2024',
                  priority: 'High',
                  isCompleted: false,
                ),
                _TaskCard(
                  title: 'Finalize guest list',
                  subtitle: 'Confirm all RSVPs and dietary requirements',
                  date: 'Dec 10, 2024',
                  priority: 'High',
                  isCompleted: false,
                ),
                _TaskCard(
                  title: 'Order flower arrangements',
                  subtitle: 'Bouquets, centerpieces, and decorations',
                  date: 'Dec 15, 2024',
                  priority: 'Medium',
                  isCompleted: true,
                ),
                _TaskCard(
                  title: 'Finalize catering menu',
                  subtitle: 'Appetizers, main course, and desserts',
                  date: 'Dec 8, 2024',
                  priority: 'High',
                  isCompleted: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Budget Page
class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final totalBudget = 25000.0;
    final spent = 16250.0;
    final remaining = totalBudget - spent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Budget Overview Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalBudget.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: spent / totalBudget,
                      minHeight: 8,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: \$${spent.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Remaining: \$${remaining.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Budget Categories
          Text(
            'Expenses by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _BudgetCategoryItem(
            category: 'Venue',
            amount: 5000,
            total: totalBudget,
            color: Colors.blue,
          ),
          _BudgetCategoryItem(
            category: 'Catering',
            amount: 6000,
            total: totalBudget,
            color: Colors.orange,
          ),
          _BudgetCategoryItem(
            category: 'Decoration',
            amount: 2500,
            total: totalBudget,
            color: Colors.pink,
          ),
          _BudgetCategoryItem(
            category: 'Photography',
            amount: 1500,
            total: totalBudget,
            color: Colors.purple,
          ),
          _BudgetCategoryItem(
            category: 'Music & Entertainment',
            amount: 1250,
            total: totalBudget,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

// Guests Page
class GuestsPage extends StatefulWidget {
  const GuestsPage({super.key});

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search guests...',
              leading: const Icon(Icons.search),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Confirmed', 'Pending', 'Declined'].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: _filterStatus == status,
                    onSelected: (bool selected) {
                      setState(() {
                        _filterStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _GuestCard(
                  name: 'John Smith',
                  email: 'john@example.com',
                  phone: '+1 (555) 123-4567',
                  status: 'Confirmed',
                  plus1: true,
                ),
                _GuestCard(
                  name: 'Sarah Johnson',
                  email: 'sarah@example.com',
                  phone: '+1 (555) 234-5678',
                  status: 'Confirmed',
                  plus1: false,
                ),
                _GuestCard(
                  name: 'Mike Davis',
                  email: 'mike@example.com',
                  phone: '+1 (555) 345-6789',
                  status: 'Pending',
                  plus1: true,
                ),
                _GuestCard(
                  name: 'Emily Wilson',
                  email: 'emily@example.com',
                  phone: '+1 (555) 456-7890',
                  status: 'Declined',
                  plus1: false,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// More Page
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<WeddingPlannerProvider>(context, listen: false);
      await provider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _MoreMenuItem(
            icon: Icons.calendar_today,
            title: 'Timeline',
            subtitle: 'View your wedding timeline',
            onTap: () {},
          ),
          _MoreMenuItem(
            icon: Icons.shopping_bag,
            title: 'Vendors',
            subtitle: 'Manage your vendors and services',
            onTap: () {},
          ),
          _MoreMenuItem(
            icon: Icons.photo_library,
            title: 'Inspiration Gallery',
            subtitle: 'Save your favorite wedding ideas',
            onTap: () {},
          ),
          _MoreMenuItem(
            icon: Icons.note,
            title: 'Notes',
            subtitle: 'Keep important notes and reminders',
            onTap: () {},
          ),
          _MoreMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and account settings',
            onTap: () {},
          ),
          _MoreMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {},
          ),
          const Divider(),
          _MoreMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out from your account',
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}

// Widget Components
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

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String priority;
  final bool isCompleted;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.priority,
    required this.isCompleted,
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
              onChanged: (_) {},
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
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryItem extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final Color color;

  const _BudgetCategoryItem({
    required this.category,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (amount / total) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: amount / total,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final bool plus1;

  const _GuestCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.plus1,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: _getStatusColor(status).withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(phone, style: Theme.of(context).textTheme.bodySmall),
            if (plus1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  label: const Text('+ 1 Guest'),
                  backgroundColor: Colors.blue[100],
                  labelStyle: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
