import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/guest_model.dart';
import '../models/budget_model.dart';
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

  // ============ LOAD ALL DATA (FIREBASE ONLY) ============
  Future<void> initializeData() async {
    await Future.wait([
      loadTasks(),
      loadGuests(),
      loadBudgets(),
    ]);
  }
}
