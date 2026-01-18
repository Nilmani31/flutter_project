import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/guest_model.dart';
import '../../providers/wedding_planner_provider.dart';

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

  void _showEditGuestDialog(BuildContext context, WeddingPlannerProvider provider, Guest guest) {
    final nameController = TextEditingController(text: guest.name);
    final emailController = TextEditingController(text: guest.email);
    final phoneController = TextEditingController(text: guest.phone);
    String status = guest.status;
    bool plus1 = guest.hasPlus1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Guest'),
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
                final updatedGuest = guest.copyWith(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  status: status,
                  hasPlus1: plus1,
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
            child: const Text('Update Guest'),
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
                            onEdit: () => _showEditGuestDialog(context, provider, guest),
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

class _GuestCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final bool hasPlus1;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GuestCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.hasPlus1,
    this.onEdit,
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
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: 8),
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
