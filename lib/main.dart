import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/wedding_planner_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/wedding_details_screen.dart';
import 'models/task_model.dart';
import 'models/guest_model.dart';
import 'models/budget_model.dart';
import 'models/vendor_model.dart';
import 'models/gallery_item_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handler - CATCH ALL CRASHES
  FlutterError.onError = (FlutterErrorDetails details) {
    print('═══════════════════════════════════════');
    print('🔴 FLUTTER CRASH DETECTED!');
    print('═══════════════════════════════════════');
    print('ERROR: ${details.exceptionAsString()}');
    print('STACK: ${details.stack}');
    print('═══════════════════════════════════════');
  };
  
  // Also catch sync errors
  try {
    print('DEBUG: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Disable App Check for development - fixes "No AppCheckProvider installed"
    try {
      print('DEBUG: Disabling App Check for development...');
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
      print('✅ App Check disabled for development testing');
    } catch (e) {
      print('⚠️  App Check setting error (non-critical): $e');
    }
  } catch (e) {
    print('⚠️  Firebase init error: $e');
  }
  
  print('DEBUG: Running app...');
  runApp(const WeddingPlannerApp());
}

class WeddingPlannerApp extends StatelessWidget {
  const WeddingPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeddingPlannerProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
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
        home: SplashScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
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

// Tasks Page
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

// Budget Page
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  void _showAddBudgetDialog(BuildContext context, WeddingPlannerProvider provider) {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Budget Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g., Venue, Catering)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
              if (categoryController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final budget = Budget(
                  category: categoryController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  notes: notesController.text,
                  createdAt: DateTime.now(),
                );
                await provider.addBudget(budget);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget item added!')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        final totalBudget = provider.budgets.fold<double>(0, (sum, b) => sum + b.amount);

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
                        '\$${totalBudget.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalBudget > 0 ? 0.65 : 0,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items: ${provider.budgets.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Allocated: \$${totalBudget.toStringAsFixed(2)}',
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
              
              // Budget Items
              Text(
                'Budget Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.budgets.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No budget items yet. Tap + to add one!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...provider.budgets.map((budget) {
                  final percentage = totalBudget > 0 ? budget.amount / totalBudget * 100 : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        title: Text(budget.category),
                        subtitle: Text('\$${budget.amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () async {
                                await provider.deleteBudget(budget.id ?? '');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Budget item deleted!')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddBudgetDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
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

  void _showAddGuestDialog(BuildContext context, WeddingPlannerProvider provider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String status = 'Pending';
    bool plus1 = false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Guest'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                items: ['Confirmed', 'Pending', 'Declined'].map((s) => 
                  DropdownMenuItem(value: s, child: Text(s))
                ).toList(),
                onChanged: (value) => status = value ?? 'Pending',
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Plus One'),
                value: plus1,
                onChanged: (value) => plus1 = value ?? false,
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
              if (nameController.text.isNotEmpty) {
                final guest = Guest(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  status: status,
                  hasPlus1: plus1,
                  createdAt: DateTime.now(),
                );
                await provider.addGuest(guest);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guest added successfully!')),
                  );
                }
              }
            },
            child: const Text('Add Guest'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        var filteredGuests = provider.guests;
        
        // Filter by status
        if (_filterStatus != 'All') {
          filteredGuests = filteredGuests.where((g) => g.status == _filterStatus).toList();
        }
        
        // Filter by search
        if (_searchController.text.isNotEmpty) {
          filteredGuests = filteredGuests
              .where((g) => g.name.toLowerCase().contains(_searchController.text.toLowerCase()))
              .toList();
        }

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
                  onChanged: (value) => setState(() {}),
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
                child: filteredGuests.isEmpty
                    ? Center(
                        child: Text(
                          'No guests found',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: filteredGuests.map((guest) {
                          return _GuestCard(
                            name: guest.name,
                            email: guest.email,
                            phone: guest.phone,
                            status: guest.status,
                            hasPlus1: guest.hasPlus1,
                            onDelete: () async {
                              await provider.deleteGuest(guest.id ?? '');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Guest removed!')),
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
            onPressed: () => _showAddGuestDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// Gallery Page (Inspiration Gallery)
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  void _showAddImageDialog(BuildContext context, WeddingPlannerProvider provider) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Saree';
    
    final List<String> categories = ['Saree', 'Lehenga', 'Jewelry', 'Makeup', 'Decoration', 'Venue', 'Other'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Image to Gallery'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g., Red Bridal Saree)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) => 
                  DropdownMenuItem(value: cat, child: Text(cat))
                ).toList(),
                onChanged: (value) => selectedCategory = value ?? 'Saree',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (why you like it)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final galleryItem = GalleryItem(
                  title: titleController.text,
                  description: descriptionController.text,
                  url: urlController.text,
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                );
                await provider.addGalleryItem(galleryItem);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image added to gallery!')),
                  );
                }
              }
            },
            child: const Text('Add to Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Inspiration Gallery'),
            elevation: 0,
          ),
          body: provider.loadingGallery
              ? const Center(child: CircularProgressIndicator())
              : provider.galleryItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No images saved yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your favorite wedding ideas',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.galleryItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.galleryItems[index];
                        return _GalleryItemCard(
                          item: item,
                          onDelete: () async {
                            await provider.deleteGalleryItem(item.id ?? '');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image removed from gallery')),
                              );
                            }
                          },
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddImageDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
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
      
      // Navigate to login page after sign out
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
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
            icon: Icons.business,
            title: 'Vendors & Products',
            subtitle: 'Browse vendors and their products',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VendorProductsPage(),
                ),
              );
            },
          ),
          _MoreMenuItem(
            icon: Icons.photo_library,
            title: 'Inspiration Gallery',
            subtitle: 'Save your favorite wedding ideas',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GalleryPage(),
                ),
              );
            },
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

// Vendors & Products Page
class VendorProductsPage extends StatefulWidget {
  const VendorProductsPage({super.key});

  @override
  State<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends State<VendorProductsPage> {
  String _selectedCategory = 'All';
  final List<String> _productCategories = [
    'All',
    'Hotel/Venue',
    'Decoration',
    'Dressing/Makeup',
    'Catering',
    'Photography',
    'Other Services',
  ];

  @override
  void initState() {
    super.initState();
    // Load vendors and products from Firebase when page loads
    final provider = Provider.of<WeddingPlannerProvider>(context, listen: false);
    provider.loadVendors();
    provider.loadProducts();
  }

  void _showVendorDetails(Vendor vendor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(vendor.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Category', value: vendor.category),
              const SizedBox(height: 12),
              _DetailRow(label: 'Description', value: vendor.description),
              const SizedBox(height: 12),
              _DetailRow(label: 'Contact', value: vendor.contact),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact request sent to ${vendor.name}'),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        // Filter products by selected category
        final filteredProducts = _selectedCategory == 'All'
            ? provider.products
            : provider.products.where((p) => p.category == _selectedCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vendors & Products'),
            elevation: 0,
          ),
          body: provider.loadingVendors || provider.loadingProducts
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: _productCategories.map((category) {
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
                    // Products List
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products in this category',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check back soon!',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              children: filteredProducts.map((product) {
                                // Find vendor for this product
                                final vendor = provider.vendors.firstWhere(
                                  (v) => v.vendorID == product.vendorID,
                                  orElse: () => Vendor(
                                    vendorID: '',
                                    password: '',
                                    name: 'Unknown Vendor',
                                    description: '',
                                    contact: '',
                                    category: '',
                                  ),
                                );
                                return _ProductCard(
                                  productName: product.title,
                                  vendorName: vendor.name,
                                  price: product.price,
                                  description: product.description,
                                  onTap: () => _showVendorDetails(vendor),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
        );
      },
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
  final Function(bool?)? onCheckboxChanged;
  final VoidCallback? onDelete;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.priority,
    required this.isCompleted,
    this.onCheckboxChanged,
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

class _GuestCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final bool hasPlus1;
  final VoidCallback? onDelete;

  const _GuestCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.hasPlus1,
    this.onDelete,
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
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: 8),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(phone, style: Theme.of(context).textTheme.bodySmall),
            if (hasPlus1)
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String productName;
  final String vendorName;
  final double price;
  final String description;
  final VoidCallback onTap;

  const _ProductCard({
    required this.productName,
    required this.vendorName,
    required this.price,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vendorName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view vendor details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
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

class _GalleryItemCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback? onDelete;

  const _GalleryItemCard({
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[300],
                    ),
                    child: item.url.isNotEmpty
                        ? Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text('Image not found', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                          ),
                  ),
                ),
                // Title & Description
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(
                            item.category ?? 'Uncategorized',
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.pink.withOpacity(0.2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete Button
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  padding: EdgeInsets.zero,
                  fixedSize: const Size(32, 32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// SPLASH SCREEN - Handles navigation safely without blocking
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: SplashScreen initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: Post frame callback - navigating');
      _navigate();
    });
  }

  Future<void> _navigate() async {
    try {
      // Check if welcome was already shown
      final prefs = await SharedPreferences.getInstance();
      final welcomeSeen = prefs.getBool('welcomeSeen') ?? false;
      
      print('DEBUG: Welcome seen: $welcomeSeen');
      print('DEBUG: Checking Firebase auth...');
      final user = FirebaseAuth.instance.currentUser;
      print('DEBUG: User: $user');
      
      if (!mounted) {
        print('DEBUG: Widget not mounted, returning');
        return;
      }

      print('DEBUG: About to navigate...');
      
      if (user != null) {
        // User is logged in → go to home
        print('DEBUG: User logged in, navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (welcomeSeen) {
        // Welcome was shown before → go to login
        print('DEBUG: Welcome seen, navigating to login');
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        // First time → show welcome
        print('DEBUG: First time, navigating to welcome');
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    } catch (e) {
      print('DEBUG: ERROR in navigation: $e');
      print('DEBUG: Stack: $e');
      if (mounted) {
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } catch (fallbackError) {
          print('DEBUG: Fallback navigation also failed: $fallbackError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Wedding Planner',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
