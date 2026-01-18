import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/guest_model.dart';
import '../models/budget_model.dart';
import '../models/wedding_model.dart';
import '../models/gallery_item_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_product_model.dart';
import '../services/firebase_service.dart';

class WeddingPlannerProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Task state
  List<Task> _tasks = [];
  bool _loadingTasks = false;
  String _taskError = '';

  // Guest state
  List<Guest> _guests = [];
  bool _loadingGuests = false;
  String _guestError = '';

  // Budget state
  List<Budget> _budgets = [];
  bool _loadingBudgets = false;
  String _budgetError = '';

  // Stats state
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _totalGuests = 0;
  double _totalBudget = 0;
  double _totalSpent = 0;

  // Auth state
  String _authError = '';
  bool _isAuthenticating = false;

  // Wedding Profile state
  WeddingProfile? _weddingProfile;
  bool _loadingWeddingProfile = false;
  String _weddingProfileError = '';
  bool _hasWeddingProfile = false;

  // Gallery state
  List<GalleryItem> _galleryItems = [];
  bool _loadingGallery = false;
  String _galleryError = '';

  // Vendor state
  List<Vendor> _vendors = [];
  bool _loadingVendors = false;
  String _vendorError = '';

  // Product state
  List<VendorProduct> _products = [];
  bool _loadingProducts = false;
  String _productError = '';

  // Getters
  List<Task> get tasks => _tasks;
  bool get loadingTasks => _loadingTasks;
  String get taskError => _taskError;

  List<Guest> get guests => _guests;
  bool get loadingGuests => _loadingGuests;
  String get guestError => _guestError;

  List<Budget> get budgets => _budgets;
  bool get loadingBudgets => _loadingBudgets;
  String get budgetError => _budgetError;

  int get completedTasks => _completedTasks;
  int get pendingTasks => _pendingTasks;
  int get totalGuests => _totalGuests;
  double get totalBudget => _totalBudget;
  double get totalSpent => _totalSpent;
  double get remainingBudget => _totalBudget - _totalSpent;

  String get authError => _authError;
  bool get isAuthenticating => _isAuthenticating;

  WeddingProfile? get weddingProfile => _weddingProfile;
  bool get loadingWeddingProfile => _loadingWeddingProfile;
  String get weddingProfileError => _weddingProfileError;
  bool get hasWeddingProfile => _hasWeddingProfile;

  List<GalleryItem> get galleryItems => _galleryItems;
  bool get loadingGallery => _loadingGallery;
  String get galleryError => _galleryError;

  List<Vendor> get vendors => _vendors;
  bool get loadingVendors => _loadingVendors;
  String get vendorError => _vendorError;

  List<VendorProduct> get products => _products;
  bool get loadingProducts => _loadingProducts;
  String get productError => _productError;

  // AUTHENTICATION METHODS
  Future<void> signUpWithEmail(String email, String password) async {
    _isAuthenticating = true;
    _authError = '';
    notifyListeners();

    try {
      await _firebaseService.signUpWithEmail(email, password);
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isAuthenticating = true;
    _authError = '';
    notifyListeners();

    try {
      await _firebaseService.signInWithEmail(email, password);
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _tasks.clear();
      _guests.clear();
      _budgets.clear();
      _authError = '';
      notifyListeners();
    } catch (e) {
      _authError = e.toString();
      notifyListeners();
    }
  }

  // ============ TASK METHODS (FIREBASE ONLY) ============
  Future<void> loadTasks() async {
    _loadingTasks = true;
    _taskError = '';
    notifyListeners();

    try {
      _tasks = await _firebaseService.getAllTasks();
      _calculateTaskStats();
    } catch (e) {
      _taskError = e.toString();
    } finally {
      _loadingTasks = false;
      notifyListeners();
    }
  }

  void _calculateTaskStats() {
    _completedTasks = _tasks.where((t) => t.isCompleted).length;
    _pendingTasks = _tasks.where((t) => !t.isCompleted).length;
  }

  Future<void> addTask(Task task) async {
    try {
      await _firebaseService.addTask(task);
      await loadTasks();
    } catch (e) {
      _taskError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _firebaseService.updateTask(task);
      await loadTasks();
    } catch (e) {
      _taskError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firebaseService.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      _taskError = e.toString();
      notifyListeners();
    }
  }

  // ============ GUEST METHODS (FIREBASE ONLY) ============
  Future<void> loadGuests() async {
    _loadingGuests = true;
    _guestError = '';
    notifyListeners();

    try {
      _guests = await _firebaseService.getAllGuests();
      _totalGuests = _guests.length;
    } catch (e) {
      _guestError = e.toString();
    } finally {
      _loadingGuests = false;
      notifyListeners();
    }
  }

  Future<void> addGuest(Guest guest) async {
    try {
      await _firebaseService.addGuest(guest);
      await loadGuests();
    } catch (e) {
      _guestError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGuest(Guest guest) async {
    try {
      await _firebaseService.updateGuest(guest);
      await loadGuests();
    } catch (e) {
      _guestError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGuest(String guestId) async {
    try {
      await _firebaseService.deleteGuest(guestId);
      await loadGuests();
    } catch (e) {
      _guestError = e.toString();
      notifyListeners();
    }
  }

  // ============ BUDGET METHODS (FIREBASE ONLY) ============
  Future<void> loadBudgets() async {
    _loadingBudgets = true;
    _budgetError = '';
    notifyListeners();

    try {
      _budgets = await _firebaseService.getAllBudgets();
      _calculateBudgetStats();
    } catch (e) {
      _budgetError = e.toString();
    } finally {
      _loadingBudgets = false;
      notifyListeners();
    }
  }

  void _calculateBudgetStats() {
    _totalBudget = _budgets.fold(0.0, (sum, b) => sum + b.amount);
    _totalSpent = _budgets.fold(0.0, (sum, b) => sum + b.spent);
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _firebaseService.addBudget(budget);
      await loadBudgets();
    } catch (e) {
      _budgetError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _firebaseService.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      _budgetError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firebaseService.deleteBudget(budgetId);
      await loadBudgets();
    } catch (e) {
      _budgetError = e.toString();
      notifyListeners();
    }
  }

  // ============ WEDDING PROFILE METHODS ============
  Future<void> saveWeddingProfile(WeddingProfile profile) async {
    _loadingWeddingProfile = true;
    _weddingProfileError = '';
    notifyListeners();

    try {
      await _firebaseService.saveWeddingProfile(profile);
      _weddingProfile = profile;
      _hasWeddingProfile = true;
    } catch (e) {
      _weddingProfileError = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _loadingWeddingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadWeddingProfile() async {
    _loadingWeddingProfile = true;
    _weddingProfileError = '';
    notifyListeners();

    try {
      final profile = await _firebaseService.getWeddingProfile();
      _weddingProfile = profile;
      _hasWeddingProfile = profile != null;
    } catch (e) {
      _weddingProfileError = e.toString();
    } finally {
      _loadingWeddingProfile = false;
      notifyListeners();
    }
  }

  Future<void> checkWeddingProfile() async {
    try {
      final hasProfile = await _firebaseService.hasWeddingProfile();
      _hasWeddingProfile = hasProfile;
      if (hasProfile) {
        await loadWeddingProfile();
      }
      notifyListeners();
    } catch (e) {
      _hasWeddingProfile = false;
      notifyListeners();
    }
  }

  // ============ GALLERY METHODS (FIREBASE ONLY) ============
  Future<void> loadGallery() async {
    _loadingGallery = true;
    _galleryError = '';
    notifyListeners();

    try {
      _galleryItems = await _firebaseService.getGalleryItems();
    } catch (e) {
      _galleryError = e.toString();
    } finally {
      _loadingGallery = false;
      notifyListeners();
    }
  }

  Future<void> addGalleryItem(GalleryItem item) async {
    try {
      await _firebaseService.addGalleryItem(item);
      await loadGallery();
    } catch (e) {
      _galleryError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGalleryItem(String itemId) async {
    try {
      await _firebaseService.deleteGalleryItem(itemId);
      await loadGallery();
    } catch (e) {
      _galleryError = e.toString();
      notifyListeners();
    }
  }

  // ============ VENDOR METHODS (FIREBASE) ============
  Future<void> loadVendors() async {
    _loadingVendors = true;
    _vendorError = '';
    notifyListeners();

    try {
      _vendors = await _firebaseService.getVendors();
    } catch (e) {
      _vendorError = e.toString();
    } finally {
      _loadingVendors = false;
      notifyListeners();
    }
  }

  Future<List<Vendor>> getVendorsByCategory(String category) async {
    try {
      return await _firebaseService.getVendorsByCategory(category);
    } catch (e) {
      _vendorError = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> addVendor(Vendor vendor) async {
    try {
      await _firebaseService.addVendor(vendor);
      await loadVendors();
    } catch (e) {
      _vendorError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      await _firebaseService.deleteVendor(vendorId);
      await loadVendors();
    } catch (e) {
      _vendorError = e.toString();
      notifyListeners();
    }
  }

  // ============ PRODUCT METHODS (FIREBASE) ============
  Future<void> loadProducts() async {
    _loadingProducts = true;
    _productError = '';
    notifyListeners();

    try {
      _products = await _firebaseService.getProducts();
    } catch (e) {
      _productError = e.toString();
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  Future<List<VendorProduct>> getProductsByCategory(String category) async {
    try {
      return await _firebaseService.getProductsByCategory(category);
    } catch (e) {
      _productError = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<VendorProduct>> getProductsByVendor(String vendorId) async {
    try {
      return await _firebaseService.getProductsByVendor(vendorId);
    } catch (e) {
      _productError = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> addProduct(VendorProduct product) async {
    try {
      await _firebaseService.addProduct(product);
      await loadProducts();
    } catch (e) {
      _productError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      _productError = e.toString();
      notifyListeners();
    }
  }

  // ============ LOAD ALL DATA (FIREBASE ONLY) ============
  Future<void> initializeData() async {
    await Future.wait([
      loadTasks(),
      loadGuests(),
      loadBudgets(),
      loadGallery(),
      loadVendors(),
      loadProducts(),
    ]);
  }
}
