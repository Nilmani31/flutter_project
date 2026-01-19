
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wedding_planner_provider.dart';



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
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _userIDController = TextEditingController(text: user?.userID ?? '');
    _nameController = TextEditingController(text: user?.name ?? '');
    _contactController = TextEditingController(text: user?.contact ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _userImageController = TextEditingController(text: user?.userImage ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');

    // Load wedding profile from provider and pre-fill fields
    final weddingProvider = Provider.of<WeddingPlannerProvider>(context, listen: false);
    final wedding = weddingProvider.weddingProfile;
    _weddingNameController = TextEditingController(text: wedding?.weddingName ?? '');
    _brideNameController = TextEditingController(text: wedding?.brideName ?? '');
    _groomNameController = TextEditingController(text: wedding?.groomName ?? '');
    _locationController = TextEditingController(text: wedding?.location ?? '');
    _budgetController = TextEditingController(text: wedding?.budget?.toString() ?? '');
    _guestsController = TextEditingController(text: wedding?.expectedGuests?.toString() ?? '');
    _notesController = TextEditingController(text: wedding?.notes ?? '');
    _selectedTheme = wedding?.theme;
    _selectedDate = wedding?.weddingDate;
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateUserProfile(
      newName: _nameController.text.trim(),
      newContact: _contactController.text.trim(),
      newUserImage: _userImageController.text.trim(),
    );
    setState(() => _loading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.authError)),
      );
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
                                    hintText: _selectedDate == null
                                        ? 'Select date'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    prefixIcon: const Icon(Icons.calendar_today),
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
