
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../../models/wedding_model.dart';
import 'dart:ui';



class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _userIDController;
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _userImageController;
  late TextEditingController _passwordController;
  // Wedding fields
  late TextEditingController _weddingNameController;
  late TextEditingController _brideNameController;
  late TextEditingController _groomNameController;
  late TextEditingController _locationController;
  late TextEditingController _budgetController;
  late TextEditingController _guestsController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;
  String? _selectedTheme;
  final List<String> _themes = [
    'Classic', 'Modern', 'Vintage', 'Romantic', 'Bohemian', 'Minimalist', 'Elegant',
  ];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers first (before build)
    _initializeControllers();
    // Then load fresh data after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _initializeControllers() {
    _userIDController = TextEditingController();
    _nameController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
    _userImageController = TextEditingController();
    _passwordController = TextEditingController();
    _weddingNameController = TextEditingController();
    _brideNameController = TextEditingController();
    _groomNameController = TextEditingController();
    _locationController = TextEditingController();
    _budgetController = TextEditingController();
    _guestsController = TextEditingController();
    _notesController = TextEditingController();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).currentUser;
      _userIDController.text = user?.userID ?? '';
      _nameController.text = user?.name ?? '';
      _contactController.text = user?.contact ?? '';
      _emailController.text = user?.email ?? '';
      _userImageController.text = user?.userImage ?? '';
      _passwordController.text = user?.password ?? '';

      // Reload wedding profile from Firebase
      final weddingProvider = Provider.of<WeddingPlannerProvider>(context, listen: false);
      await weddingProvider.loadWeddingProfile();
      
      final wedding = weddingProvider.weddingProfile;
      _weddingNameController.text = wedding?.weddingName ?? '';
      _brideNameController.text = wedding?.brideName ?? '';
      _groomNameController.text = wedding?.groomName ?? '';
      _locationController.text = wedding?.location ?? '';
      _budgetController.text = wedding?.budget?.toString() ?? '';
      _guestsController.text = wedding?.expectedGuests?.toString() ?? '';
      _notesController.text = wedding?.notes ?? '';
      
      if (mounted) {
        setState(() {
          _selectedTheme = wedding?.theme;
          _selectedDate = wedding?.weddingDate;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  @override
  void dispose() {
    _userIDController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _userImageController.dispose();
    _passwordController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select wedding date')),
      );
      return;
    }
    
    setState(() => _loading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final weddingProvider = Provider.of<WeddingPlannerProvider>(context, listen: false);
      
      // Save user profile
      final userSuccess = await userProvider.updateUserProfile(
        newName: _nameController.text.trim(),
        newContact: _contactController.text.trim(),
        newUserImage: _userImageController.text.trim(),
      );
      
      if (userSuccess) {
        // Save wedding profile
        final weddingProfile = WeddingProfile(
          id: weddingProvider.weddingProfile?.id,
          userId: weddingProvider.weddingProfile?.userId,
          weddingName: _weddingNameController.text.trim(),
          brideName: _brideNameController.text.trim(),
          groomName: _groomNameController.text.trim(),
          weddingDate: _selectedDate!,
          location: _locationController.text.trim(),
          theme: _selectedTheme,
          budget: double.tryParse(_budgetController.text.trim()),
          expectedGuests: int.tryParse(_guestsController.text.trim()),
          notes: _notesController.text.trim(),
          createdAt: weddingProvider.weddingProfile?.createdAt,
        );
        
        await weddingProvider.saveWeddingProfile(weddingProfile);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile and wedding details saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userProvider.authError)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('No user information available.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar with image preview
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: (_userImageController.text.isNotEmpty)
                                ? NetworkImage(_userImageController.text)
                                : null,
                            child: _userImageController.text.isEmpty
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: Icon(Icons.edit, color: Colors.purple, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // User Info Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _userIDController,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.account_circle_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _userImageController,
                              decoration: const InputDecoration(
                                labelText: 'Profile Image URL',
                                prefixIcon: Icon(Icons.image_outlined),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Wedding Info Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Wedding Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _weddingNameController,
                              decoration: const InputDecoration(
                                labelText: 'Wedding Name/Title',
                                prefixIcon: Icon(Icons.card_giftcard),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _brideNameController,
                              decoration: const InputDecoration(
                                labelText: 'Bride Name',
                                prefixIcon: Icon(Icons.female),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _groomNameController,
                              decoration: const InputDecoration(
                                labelText: 'Groom Name',
                                prefixIcon: Icon(Icons.male),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Wedding Date',
                                    hintText: 'Select date',
                                    prefixIcon: const Icon(Icons.calendar_today),
                                  ),
                                  controller: TextEditingController(
                                    text: _selectedDate == null
                                        ? ''
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Wedding Location',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedTheme,
                              decoration: const InputDecoration(
                                labelText: 'Wedding Theme',
                                prefixIcon: Icon(Icons.palette_outlined),
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
                            TextFormField(
                              controller: _guestsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Expected Guests',
                                prefixIcon: Icon(Icons.people_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _budgetController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Budget',
                                prefixIcon: Icon(Icons.attach_money_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Additional Notes',
                                prefixIcon: Icon(Icons.note_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color.fromARGB(31, 0, 0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.transparent),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                                'Save',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 123, 121, 124),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
