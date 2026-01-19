import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wedding_model.dart';
import '../providers/wedding_planner_provider.dart';

class WeddingDetailsScreen extends StatefulWidget {
  const WeddingDetailsScreen({super.key});

  @override
  State<WeddingDetailsScreen> createState() => _WeddingDetailsScreenState();
}

class _WeddingDetailsScreenState extends State<WeddingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weddingNameController = TextEditingController();
  final _brideNameController = TextEditingController();
  final _groomNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _guestsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTheme;
  bool _isLoading = false;

  final List<String> _themes = [
    'Classic',
    'Modern',
    'Vintage',
    'Romantic',
    'Bohemian',
    'Minimalist',
    'Elegant',
  ];

  @override
  void dispose() {
    _weddingNameController.dispose();
    _brideNameController.dispose();
    _groomNameController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _guestsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWeddingDetails() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select wedding date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<WeddingPlannerProvider>(context, listen: false);
      
      final weddingProfile = WeddingProfile(
        weddingName: _weddingNameController.text,
        brideName: _brideNameController.text,
        groomName: _groomNameController.text,
        weddingDate: _selectedDate!,
        location: _locationController.text,
        theme: _selectedTheme,
        budget: double.tryParse(_budgetController.text),
        expectedGuests: int.tryParse(_guestsController.text),
        notes: _notesController.text,
      );

      await provider.saveWeddingProfile(weddingProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wedding details saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tell Us About Your Wedding',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help us customize your wedding planning experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Wedding Name
                TextFormField(
                  controller: _weddingNameController,
                  decoration: InputDecoration(
                    labelText: 'Wedding Name/Title',
                    hintText: 'e.g., Sarah & John\'s Wedding',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter wedding name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bride Name
                TextFormField(
                  controller: _brideNameController,
                  decoration: InputDecoration(
                    labelText: 'Bride Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bride name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Groom Name
                TextFormField(
                  controller: _groomNameController,
                  decoration: InputDecoration(
                    labelText: 'Groom Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter groom name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Wedding Date
                GestureDetector(
                  onTap: _selectDate,
                  child: TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Wedding Date',
                      hintText: _selectedDate == null
                          ? 'Select date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Wedding Location',
                    hintText: 'City or Venue',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Theme Selection
                DropdownButtonFormField<String>(
                  value: _selectedTheme,
                  decoration: InputDecoration(
                    labelText: 'Wedding Theme',
                    prefixIcon: const Icon(Icons.palette),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _themes.map((theme) {
                    return DropdownMenuItem(
                      value: theme,
                      child: Text(theme),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTheme = value);
                  },
                ),
                const SizedBox(height: 16),

                // Expected Guests
                TextFormField(
                  controller: _guestsController,
                  decoration: InputDecoration(
                    labelText: 'Expected Guests',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Budget
                TextFormField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: 'Budget',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveWeddingDetails,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Wedding Details',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
