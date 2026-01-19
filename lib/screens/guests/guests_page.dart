import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/wedding_planner_provider.dart';
import 'dart:ui';

class GuestsPage extends StatefulWidget {
  const GuestsPage({super.key});

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  String _selectedStatus = 'All';
  final List<String> _statusFilters = ['All', 'Confirmed', 'Pending', 'Declined'];

  void _showAddGuestDialog(BuildContext context, WeddingPlannerProvider provider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    int guestCount = 1;
    String status = 'Pending';

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
                child: SingleChildScrollView(
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
                            child: const Icon(Icons.person_add, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Text('Add New Guest',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF3D2E42), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Guest Name',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setState) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number of People Invited', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E))),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Color(0xFFB76E79)),
                                    onPressed: () {
                                      setState(() {
                                        if (guestCount > 1) guestCount--;
                                      });
                                    },
                                  ),
                                  Text(
                                    guestCount.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF3D2E42)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFFB76E79)),
                                    onPressed: () {
                                      setState(() {
                                        guestCount++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: status,
                        items: ['Confirmed', 'Pending', 'Declined'].map((s) =>
                          DropdownMenuItem(value: s, child: Text(s))
                        ).toList(),
                        onChanged: (value) => status = value ?? 'Pending',
                        decoration: InputDecoration(
                          labelText: 'Status',
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
                              if (nameController.text.isNotEmpty) {
                                final guest = Guest(
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  status: status,
                                  hasPlus1: guestCount > 1,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGuestDetailsDialog(BuildContext context, WeddingPlannerProvider provider, Guest guest) {
    final nameController = TextEditingController(text: guest.name);
    final emailController = TextEditingController(text: guest.email);
    final phoneController = TextEditingController(text: guest.phone);
    int guestCount = guest.hasPlus1 ? 2 : 1;
    String status = guest.status;

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
                child: SingleChildScrollView(
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
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Text('Guest Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF3D2E42), fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Guest Name',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setState) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number of People Invited', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E))),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Color(0xFFB76E79)),
                                    onPressed: () {
                                      setState(() {
                                        if (guestCount > 1) guestCount--;
                                      });
                                    },
                                  ),
                                  Text(
                                    guestCount.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF3D2E42)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFFB76E79)),
                                    onPressed: () {
                                      setState(() {
                                        guestCount++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: status,
                        items: ['Confirmed', 'Pending', 'Declined'].map((s) =>
                          DropdownMenuItem(value: s, child: Text(s))
                        ).toList(),
                        onChanged: (value) => status = value ?? 'Pending',
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF7A5C5E)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB76E79),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: () async {
                              if (nameController.text.isNotEmpty) {
                                final updatedGuest = guest.copyWith(
                                  name: nameController.text,
                                  email: emailController.text,
                                  phone: phoneController.text,
                                  status: status,
                                  hasPlus1: guestCount > 1,
                                  updatedAt: DateTime.now(),
                                );
                                await provider.updateGuest(updatedGuest);
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Guest updated successfully!')),
                                  );
                                }
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D2E42),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.delete, size: 20),
                            label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: () async {
                              await provider.deleteGuest(guest.id ?? '');
                              Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Guest deleted!')),
                                );
                              }
                            },
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF7A5C5E),
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            ),
                            child: const Text('Close'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        final filteredGuests = _selectedStatus == 'All'
            ? provider.guests
            : provider.guests.where((g) => g.status == _selectedStatus).toList();

        // Calculate statistics
        final confirmed = provider.guests.where((g) => g.status == 'Confirmed').length;
        final pending = provider.guests.where((g) => g.status == 'Pending').length;
        final declined = provider.guests.where((g) => g.status == 'Declined').length;
        final total = provider.guests.length;

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
                          'Guests',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: const Color.fromARGB(255, 61, 46, 66),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Statistics Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatCard(
                              label: 'Total',
                              count: total,
                              color: getStatusColorByStatus('Total'),
                            ),
                            _StatCard(
                              label: 'Confirmed',
                              count: confirmed,
                              color: getStatusColorByStatus('Confirmed'),
                            ),
                            _StatCard(
                              label: 'Pending',
                              count: pending,
                              color: getStatusColorByStatus('Pending'),
                            ),
                            _StatCard(
                              label: 'Declined',
                              count: declined,
                              color: getStatusColorByStatus('Declined'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: _statusFilters.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(status),
                                  selected: _selectedStatus == status,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedStatus = status;
                                    });
                                  },
                                  selectedColor: const Color.fromARGB(255, 103, 27, 52).withOpacity(0.15),
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  labelStyle: TextStyle(
                                    color: _selectedStatus == status
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
                if (filteredGuests.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No guests in this category',
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
                          final guest = filteredGuests[i];
                          return GestureDetector(
                            onTap: () => _showGuestDetailsDialog(context, provider, guest),
                            child: _ModernGuestCard(
                              name: guest.name,
                              email: guest.email,
                              phone: guest.phone,
                              status: guest.status,
                              hasPlus1: guest.hasPlus1,
                            ),
                          );
                        },
                        childCount: filteredGuests.length,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: () => _showAddGuestDialog(context, provider),
                backgroundColor: const Color.fromARGB(255, 53, 30, 57),
                child: const Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 76, 76, 75),
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

// Color helper for consistent status colors
Color getStatusColorByStatus(String status) {
  switch (status) {
    case 'Confirmed':
      return Color.fromARGB(255, 76, 76, 75);
    case 'Pending':
      return Color.fromARGB(255, 76, 76, 75);
    case 'Declined':
      return Color.fromARGB(255, 76, 76, 75);
    case 'Total':
      return Color.fromARGB(255, 76, 76, 75);
    default:
      return Color.fromARGB(255, 76, 76, 75);
  }
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D2E42),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Guest Card Widget (glassmorphism style)
class _ModernGuestCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final bool hasPlus1;

  const _ModernGuestCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.hasPlus1,
  });

  Color getStatusColor() {
    return getStatusColorByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3D2E42),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getStatusColor().withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: getStatusColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: getStatusColor(),
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
                    const Icon(Icons.phone, size: 16, color: Color(0xFFB76E79)),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: const TextStyle(color: Color(0xFF7A5C5E), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (hasPlus1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB76E79).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+1 Guest',
                          style: TextStyle(
                            color: Color(0xFFB76E79),
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

