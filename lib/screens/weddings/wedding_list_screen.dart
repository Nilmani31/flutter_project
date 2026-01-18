import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../../models/wedding_model.dart';

class WeddingListScreen extends StatefulWidget {
  const WeddingListScreen({Key? key}) : super(key: key);

  @override
  State<WeddingListScreen> createState() => _WeddingListScreenState();
}

class _WeddingListScreenState extends State<WeddingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch weddings when screen loads
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weddings'),
        centerTitle: true,
      ),
      body: Consumer<WeddingPlannerProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Create Wedding Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeddingFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Wedding'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Wedding List
                Expanded(
                  child: provider.loadingWeddingProfile
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: 0, // TODO: Replace with actual wedding list
                          itemBuilder: (context, index) {
                            return const SizedBox();
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WeddingFormScreen extends StatefulWidget {
  const WeddingFormScreen({Key? key}) : super(key: key);

  @override
  State<WeddingFormScreen> createState() => _WeddingFormScreenState();
}

class _WeddingFormScreenState extends State<WeddingFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _weddingNameController;
  late TextEditingController _brideNameController;
  late TextEditingController _groomNameController;
  late TextEditingController _locationController;
  late TextEditingController _themeController;
  late TextEditingController _budgetController;
  late TextEditingController _guestsController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _weddingNameController = TextEditingController();
    _brideNameController = TextEditingController();
    _groomNameController = TextEditingController();
    _locationController = TextEditingController();
    _themeController = TextEditingController();
    _budgetController = TextEditingController();
    _guestsController = TextEditingController();
  }

  @override
  void dispose() {
    _weddingNameController.dispose();
    _brideNameController.dispose();
    _groomNameController.dispose();
    _locationController.dispose();
    _themeController.dispose();
    _budgetController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWedding() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final wedding = WeddingProfile(
        weddingName: _weddingNameController.text,
        brideName: _brideNameController.text,
        groomName: _groomNameController.text,
        weddingDate: _selectedDate!,
        location: _locationController.text,
        theme: _themeController.text,
        budget: double.tryParse(_budgetController.text),
        expectedGuests: int.tryParse(_guestsController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Implement Firebase integration
      // Uncomment below to save wedding through provider
      // final weddingProvider = context.read<WeddingPlannerProvider>();
      // await weddingProvider.addWedding(wedding);
      
      // For now, just show success message
      print('Wedding created: ${wedding.weddingName}');

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wedding created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wedding'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _weddingNameController,
                decoration: InputDecoration(
                  labelText: 'Wedding Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brideNameController,
                decoration: InputDecoration(
                  labelText: 'Bride Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groomNameController,
                decoration: InputDecoration(
                  labelText: 'Groom Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.purple),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Wedding Date'
                            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _themeController,
                decoration: InputDecoration(
                  labelText: 'Theme',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Budget',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Expected Guests',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveWedding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Create Wedding',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
