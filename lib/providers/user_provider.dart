import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../models/wedding_model.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String _authError = '';
  List<User> _allUsers = [];

  // Wedding data for current user
  List<WeddingProfile>? _userWeddings;
  bool _loadingUserWeddings = false;
  String _weddingError = '';

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticating => _isAuthenticating;
  String get authError => _authError;
  List<User> get allUsers => _allUsers;
  List<WeddingProfile>? get userWeddings => _userWeddings;
  bool get loadingUserWeddings => _loadingUserWeddings;
  String get weddingError => _weddingError;

  // User Signup
  Future<bool> userSignup({
    required String userID,
    required String password,
    required String name,
    required String contact,
    required String email,
    String userImage = '',
  }) async {
    _isAuthenticating = true;
    _authError = '';
    notifyListeners();

    try {
      // Create user object
      User newUser = User(
        userID: userID,
        password: password,
        name: name,
        contact: contact,
        userImage: userImage,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sign up using Firebase service
      String userId = await _firebaseService.signUpUser(newUser);
      newUser.id = userId;

      _allUsers.add(newUser);
      _currentUser = newUser;
      _isAuthenticated = true;
      newUser.userSignup();
      _authError = '';
      _isAuthenticating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = 'Signup failed: $e';
      print('Error: $_authError');
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  // User Login
  Future<bool> userLogin({
    required String userID,
    required String password,
  }) async {
    _isAuthenticating = true;
    _authError = '';
    notifyListeners();

    try {
      print('DEBUG: Attempting login with email: $userID');
      
      // Retry logic for network errors
      firebase_auth.UserCredential? userCredential;
      int retries = 3;
      Exception? lastError;
      
      while (retries > 0) {
        try {
          print('DEBUG: Login attempt (retries left: $retries)');
          userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
            email: userID,
            password: password,
          ).timeout(
            const Duration(seconds: 20),
            onTimeout: () => throw Exception('Login timeout - try again'),
          );
          break; // Success!
        } catch (e) {
          lastError = e as Exception;
          retries--;
          if (retries > 0) {
            print('DEBUG: Login failed, retrying... Error: $e');
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }

      if (userCredential?.user != null) {
        print('DEBUG: Firebase login successful: ${userCredential!.user!.uid}');
        
        // Create local user object
        User newUser = User(
          id: userCredential.user!.uid,
          userID: userID,
          password: password,
          name: userID,
          contact: '',
          userImage: '',
          email: userCredential.user!.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _currentUser = newUser;
        _isAuthenticated = true;
        newUser.userLogin();
        
        print('DEBUG: Login successful for $userID');
        _authError = '';
        _isAuthenticating = false;
        notifyListeners();
        return true;
      }
      
      throw lastError ?? Exception('Login failed: No user returned');
    } catch (e) {
      _authError = 'Login failed: $e';
      print('ERROR in login: $_authError');
      _currentUser = null;
      _isAuthenticated = false;
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  // User Logout
  Future<void> userLogout() async {
    try {
      print('DEBUG: Starting logout');
      
      if (_currentUser != null) {
        _currentUser!.userLogout();
      }
      
      // Sign out from Firebase Auth
      await firebase_auth.FirebaseAuth.instance.signOut();
      print('DEBUG: Firebase sign out successful');

      _currentUser = null;
      _isAuthenticated = false;
      _userWeddings = null;
      _authError = '';
      notifyListeners();
      
      print('DEBUG: User logged out successfully');
    } catch (e) {
      _authError = 'Logout failed: $e';
      print('ERROR in logout: $_authError');
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile({
    required String newName,
    String? newContact,
    String? newUserImage,
  }) async {
    if (_currentUser == null) {
      _authError = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      _currentUser!.userUpdateProfile(newName);
      if (newContact != null) _currentUser!.contact = newContact;
      if (newUserImage != null) _currentUser!.userImage = newUserImage;
      _currentUser!.updatedAt = DateTime.now();

      // TODO: Implement Firebase update
      await _firebaseService.updateUserProfile(_currentUser!);

      // Update in all users list
      final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        _allUsers[index] = _currentUser!;
      }

      _authError = '';
      notifyListeners();
      return true;
    } catch (e) {
      _authError = 'Profile update failed: $e';
      print('Error: $_authError');
      notifyListeners();
      return false;
    }
  }

  // Fetch all user's weddings
  Future<void> fetchUserWeddings() async {
    if (_currentUser == null) {
      _weddingError = 'No user logged in';
      notifyListeners();
      return;
    }

    _loadingUserWeddings = true;
    _weddingError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase fetch
      // _userWeddings = await _firebaseService.getUserWeddings(_currentUser!.id!);
      _weddingError = '';
    } catch (e) {
      _weddingError = 'Failed to fetch weddings: $e';
      print('Error: $_weddingError');
    } finally {
      _loadingUserWeddings = false;
      notifyListeners();
    }
  }

  // Create new wedding for current user
  Future<bool> createWeddingForUser(WeddingProfile wedding) async {
    if (_currentUser == null) {
      _weddingError = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      wedding.userId = _currentUser!.id;

      // TODO: Implement Firebase integration
      // String weddingId = await _firebaseService.addWedding(wedding);
      // _currentUser!.addWeddingToUser(weddingId);
      // await _firebaseService.updateUser(_currentUser!);

      if (_userWeddings == null) {
        _userWeddings = [];
      }
      _userWeddings!.add(wedding);

      _weddingError = '';
      notifyListeners();
      return true;
    } catch (e) {
      _weddingError = 'Failed to create wedding: $e';
      print('Error: $_weddingError');
      notifyListeners();
      return false;
    }
  }

  // Delete wedding from user's account
  Future<bool> deleteWeddingFromUser(String weddingId) async {
    if (_currentUser == null) {
      _weddingError = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      // TODO: Implement Firebase integration
      // await _firebaseService.deleteWedding(weddingId);
      // _currentUser!.removeWeddingFromUser(weddingId);
      // await _firebaseService.updateUser(_currentUser!);

      if (_userWeddings != null) {
        _userWeddings!.removeWhere((w) => w.id == weddingId);
      }

      _weddingError = '';
      notifyListeners();
      return true;
    } catch (e) {
      _weddingError = 'Failed to delete wedding: $e';
      print('Error: $_weddingError');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _authError = '';
    notifyListeners();
  }

  // Clear wedding error
  void clearWeddingError() {
    _weddingError = '';
    notifyListeners();
  }
}
