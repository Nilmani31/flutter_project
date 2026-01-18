import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../weddings/wedding_list_screen.dart';
import '../vendors/vendor_list_screen.dart';
import '../gallery/gallery_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const WeddingListScreen(),
    const VendorListScreen(),
    const GalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Planner'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 65, 22, 73),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'logout') {
                context.read<UserProvider>().userLogout();
                Navigator.of(context).pushReplacementNamed('/login');
              } else if (result == 'profile') {
                // Navigate to profile screen
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
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
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 65, 22, 73),
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Weddings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _welcomeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOut),
    );

    _welcomeAnimationController.forward();
    _slideAnimationController.forward();

    _startCarouselAutoScroll();
  }

  void _startCarouselAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentCarouselIndex = (_currentCarouselIndex + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _welcomeAnimationController.dispose();
    _slideAnimationController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Animated Welcome Card with Gradient
              ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(
                  CurvedAnimation(parent: _welcomeAnimationController, curve: Curves.elasticOut),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 65, 22, 73),
                        const Color.fromARGB(255, 103, 27, 52),
                        const Color.fromARGB(255, 142, 36, 68),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -50,
                        bottom: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back! 👋',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 26,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${user?.name}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.15),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                  ),
                                  child: Icon(Icons.person, size: 32, color: Colors.white.withOpacity(0.8)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7), size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${user?.email}',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.85),
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, color: Colors.white.withOpacity(0.7), size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${user?.contact}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Featured Tips Carousel
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wedding Tips & Ideas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 61, 46, 66),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: PageView(
                          onPageChanged: (index) {
                            setState(() {
                              _currentCarouselIndex = index;
                            });
                          },
                          children: [
                            _TipCard(
                              title: '💍 Perfect Ring Choice',
                              description: 'Explore trending ring styles for your special day',
                              color: const Color.fromARGB(255, 233, 30, 99),
                            ),
                            _TipCard(
                              title: '🎂 Cake Design Trends',
                              description: 'Discover the latest wedding cake designs',
                              color: const Color.fromARGB(255, 255, 152, 0),
                            ),
                            _TipCard(
                              title: '📸 Photography Ideas',
                              description: 'Get creative photo pose suggestions',
                              color: const Color.fromARGB(255, 33, 150, 243),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Carousel Dots
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentCarouselIndex == index ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentCarouselIndex == index
                                    ? const Color.fromARGB(255, 65, 22, 73)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Your Stats Title
              Text(
                'Your Planning Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              // Interactive Stat Cards with Hover Effect
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  _InteractiveStatCard(
                    title: 'Weddings',
                    count: '${user?.weddingIds.length ?? 0}',
                    icon: Icons.card_giftcard,
                    color: const Color.fromARGB(255, 33, 150, 243),
                    onTap: () {},
                  ),
                  _InteractiveStatCard(
                    title: 'Vendors',
                    count: '0',
                    icon: Icons.business,
                    color: const Color.fromARGB(255, 76, 175, 80),
                    onTap: () {},
                  ),
                  _InteractiveStatCard(
                    title: 'Tasks',
                    count: '0',
                    icon: Icons.task_alt,
                    color: const Color.fromARGB(255, 255, 152, 0),
                    onTap: () {},
                  ),
                  _InteractiveStatCard(
                    title: 'Gallery',
                    count: '0',
                    icon: Icons.photo_library,
                    color: const Color.fromARGB(255, 233, 30, 99),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions Title
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              // Premium Create Wedding Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 65, 22, 73), Color.fromARGB(255, 103, 27, 52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to create wedding
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.add_circle_outline, size: 22, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Create New Wedding',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Browse Vendors Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    border: Border.all(color: const Color.fromARGB(255, 103, 27, 52), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to vendors
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_center_outlined, size: 22, color: const Color.fromARGB(255, 103, 27, 52)),
                            const SizedBox(width: 12),
                            Text(
                              'Browse Vendors',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 103, 27, 52),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Upcoming Events Section
              Text(
                'Upcoming Events 📅',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _EventCountdownCard(
                eventName: 'Next Wedding',
                daysLeft: 47,
              ),
              const SizedBox(height: 28),

              // Planning Checklist Section
              Text(
                'Planning Checklist ✓',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              _PlanningChecklistItem(title: 'Book Venue', isCompleted: true),
              _PlanningChecklistItem(title: 'Hire Photographer', isCompleted: true),
              _PlanningChecklistItem(title: 'Order Flowers', isCompleted: false),
              _PlanningChecklistItem(title: 'Choose Menu', isCompleted: false),
              const SizedBox(height: 28),

              // Interactive Stats with Animations
              Text(
                'Planning Progress 🎯',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Progress Ring
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: _AnimatedProgressRing(
                        progress: 0.65,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const Color.fromARGB(255, 65, 22, 73),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '65% Complete',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 65, 22, 73),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re doing great! Keep it up.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Achievement Badges
              Text(
                'Achievements 🏆',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AchievementBadge(
                    icon: Icons.card_giftcard,
                    title: 'First Wedding',
                    isUnlocked: true,
                  ),
                  _AchievementBadge(
                    icon: Icons.shopping_bag,
                    title: '5 Vendors',
                    isUnlocked: false,
                  ),
                  _AchievementBadge(
                    icon: Icons.image,
                    title: '50 Photos',
                    isUnlocked: false,
                  ),
                  _AchievementBadge(
                    icon: Icons.stars,
                    title: 'Perfect Plan',
                    isUnlocked: false,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Wedding Mood Board Carousel
              Text(
                'Inspiration Gallery ✨',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 61, 46, 66),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _InspirationCard(
                      emoji: '💍',
                      title: 'Ring Ideas',
                      color: const Color.fromARGB(255, 233, 30, 99),
                    ),
                    const SizedBox(width: 12),
                    _InspirationCard(
                      emoji: '🎂',
                      title: 'Cake Designs',
                      color: const Color.fromARGB(255, 255, 152, 0),
                    ),
                    const SizedBox(width: 12),
                    _InspirationCard(
                      emoji: '💐',
                      title: 'Flowers',
                      color: const Color.fromARGB(255, 76, 175, 80),
                    ),
                    const SizedBox(width: 12),
                    _InspirationCard(
                      emoji: '🎊',
                      title: 'Decorations',
                      color: const Color.fromARGB(255, 33, 150, 243),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// Event Countdown Card
class _EventCountdownCard extends StatefulWidget {
  final String eventName;
  final int daysLeft;

  const _EventCountdownCard({
    required this.eventName,
    required this.daysLeft,
  });

  @override
  State<_EventCountdownCard> createState() => _EventCountdownCardState();
}

class _EventCountdownCardState extends State<_EventCountdownCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 65, 22, 73).withOpacity(0.9),
              const Color.fromARGB(255, 103, 27, 52).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 22, 73).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.daysLeft} days to go',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Text(
                '${widget.daysLeft}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Planning Checklist Item
class _PlanningChecklistItem extends StatefulWidget {
  final String title;
  final bool isCompleted;

  const _PlanningChecklistItem({
    required this.title,
    required this.isCompleted,
  });

  @override
  State<_PlanningChecklistItem> createState() => _PlanningChecklistItemState();
}

class _PlanningChecklistItemState extends State<_PlanningChecklistItem> with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isCompleted;
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (_isChecked) {
      _checkController.forward();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggleCheck() {
    setState(() {
      _isChecked = !_isChecked;
    });
    if (_isChecked) {
      _checkController.forward();
    } else {
      _checkController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCheck,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isChecked ? const Color.fromARGB(255, 76, 175, 80).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: _isChecked ? const Color.fromARGB(255, 76, 175, 80) : Colors.grey.shade200,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
              ),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isChecked ? const Color.fromARGB(255, 76, 175, 80) : Colors.transparent,
                  border: Border.all(
                    color: _isChecked ? const Color.fromARGB(255, 76, 175, 80) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: _isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isChecked ? Colors.grey.shade500 : Colors.black87,
                  decoration: _isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Progress Ring
class _AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;

  const _AnimatedProgressRing({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  State<_AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<_AnimatedProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProgressRingPainter(
            progress: _animation.value,
            strokeWidth: widget.strokeWidth,
            backgroundColor: widget.backgroundColor,
            valueColor: widget.valueColor,
          ),
          size: const Size(120, 120),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    final paint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Achievement Badge
class _AchievementBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isUnlocked;

  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.isUnlocked,
  });

  @override
  State<_AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<_AchievementBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.isUnlocked) {
          _controller.repeat(reverse: true);
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? (1.0 + (_controller.value * 0.1)) : 1.0,
            child: Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.isUnlocked ? Colors.white : Colors.grey.shade100,
                border: Border.all(
                  color: widget.isUnlocked
                      ? const Color.fromARGB(255, 255, 152, 0)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  if (widget.isUnlocked)
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 152, 0).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 32,
                    color: widget.isUnlocked
                        ? const Color.fromARGB(255, 255, 152, 0)
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: widget.isUnlocked ? Colors.black87 : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Inspiration Card
class _InspirationCard extends StatefulWidget {
  final String emoji;
  final String title;
  final Color color;

  const _InspirationCard({
    required this.emoji,
    required this.title,
    required this.color,
  });

  @override
  State<_InspirationCard> createState() => _InspirationCardState();
}

class _InspirationCardState extends State<_InspirationCard> with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _rotateController.forward(),
      onExit: (_) => _rotateController.reverse(),
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(_rotateController.value * 0.3),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3 + (_rotateController.value * 0.2)),
                    blurRadius: 16,
                    offset: Offset(0, 4 + (_rotateController.value * 4)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -15,
                    top: -15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Tip Card Widget
class _TipCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_hoverController.value * 0.05),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color,
                    widget.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3 + (_hoverController.value * 0.2)),
                    blurRadius: 16,
                    offset: Offset(0, 4 + (_hoverController.value * 4)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Interactive Stat Card Widget
class _InteractiveStatCard extends StatefulWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InteractiveStatCard> createState() => _InteractiveStatCardState();
}

class _InteractiveStatCardState extends State<_InteractiveStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tapScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _tapScale,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.1),
                        widget.color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 40, color: widget.color),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.count,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
