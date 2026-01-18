import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _backgroundController;
  int _currentImageIndex = 0;

  final List<String> _backgroundImages = [
    'assets/wedding_bg1.jpg',
    'assets/wedding_bg2.jpg',
    'assets/wedding_bg4.jpg',
    'assets/wedding_bg5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = PageController();
    // Auto-scroll background every 5 seconds
    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (mounted) {
      _backgroundController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 5), _autoScroll);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _markWelcomeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeSeen', true);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Carousel
          PageView.builder(
            controller: _backgroundController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index % _backgroundImages.length;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_backgroundImages[index % _backgroundImages.length]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              
              // Logo Image
              Image.asset(
                'assets/logo.png',
                height: 500,
                width: 500,
              ),
              
              const SizedBox(height: 5),
              
              Text(
                'Wedding Planner',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Plan your perfect wedding with ease. Organize tasks, manage budget, track guests, and save inspiration all in one place.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),

              // Dot Indicators for Background Images
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _backgroundImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _currentImageIndex == index ? 10 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(255, 65, 22, 73), const Color.fromARGB(255, 103, 27, 52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: _markWelcomeComplete,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
