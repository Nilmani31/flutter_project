import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../vendors/vendor_products_page.dart';
import '../gallery/gallery_page.dart';
import 'profile_page.dart';
import 'dart:ui';

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
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
                child: Text(
                  'More',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color.fromARGB(255, 61, 46, 66),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ModernMoreMenuItem(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(),
                        ),
                      );
                    },
                  ),
                  _ModernMoreMenuItem(
                    icon: Icons.calendar_today,
                    title: 'Timeline',
                    subtitle: 'View your wedding timeline',
                    onTap: () {},
                  ),
                  _ModernMoreMenuItem(
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
                  _ModernMoreMenuItem(
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
                  _ModernMoreMenuItem(
                    icon: Icons.note,
                    title: 'Notes',
                    subtitle: 'Keep important notes and reminders',
                    onTap: () {},
                  ),
                  _ModernMoreMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences and account settings',
                    onTap: () {},
                  ),
                  _ModernMoreMenuItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ModernMoreMenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out from your account',
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Modern More Menu Item Widget (glassmorphism style)
class _ModernMoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ModernMoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
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
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? Colors.redAccent.withOpacity(0.16)
                          : const Color(0xFFB76E79).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive ? Colors.redAccent : const Color(0xFFB76E79),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDestructive
                                    ? Colors.redAccent
                                    : const Color(0xFF3D2E42),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[500],
                    size: 24,
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

// Legacy More Menu Item Widget (kept for compatibility)
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

