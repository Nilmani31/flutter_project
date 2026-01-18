import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../vendors/vendor_products_page.dart';
import '../gallery/gallery_page.dart';

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

// More Menu Item Widget
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
