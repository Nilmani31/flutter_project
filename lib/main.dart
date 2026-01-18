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
import 'screens/home/dashboard_page.dart';
import 'screens/tasks/tasks_page.dart';
import 'screens/budget/budget_page.dart';
import 'screens/guests/guests_page.dart';
import 'screens/more/more_page.dart';
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
      } else {
        // Show welcome screen first (new users or returning users who logged out)
        print('DEBUG: Navigating to welcome');
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
