import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/task_model.dart';
import '../models/guest_model.dart';
import '../models/budget_model.dart';
import '../models/wedding_model.dart';
import '../models/user_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_product_model.dart';
import '../models/gallery_item_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // AUTHENTICATION
  Future<String> signUpUser(User user) async {
    try {
      print('DEBUG: Starting signup for ${user.email}');
      
      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      print('DEBUG: Firebase Auth user created: ${userCredential.user?.uid}');

      // Save complete user details in Firestore 'users' collection
      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        print('DEBUG: Saving user details to Firestore for $userId');
        
        final userData = {
          'uid': userId,
          'userID': user.userID,
          'email': user.email,
          'name': user.name,
          'contact': user.contact,
          'userImage': user.userImage,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
          'weddingIds': [],
        };
        
        print('DEBUG: User data to save: $userData');
        
        await _firestore.collection('users').doc(userId).set(userData);
        
        print('DEBUG: User successfully saved to Firestore!');
        return userId;
      }
      throw Exception('User creation failed');
    } catch (e) {
      print('ERROR in signUpUser: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details in Firestore 'users' collection
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': email.split('@')[0], // Username from email
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        }).catchError((e) {
          // If document doesn't exist, just skip the update
          print('Could not update login time: $e');
        });
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // WEDDING PROFILE OPERATIONS
  Future<void> saveWeddingProfile(WeddingProfile profile) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      final docId = profile.id ?? userId; // Use user ID as wedding profile ID
      
      await _firestore.collection('weddingProfiles').doc(docId).set({
        'userId': userId,
        'weddingName': profile.weddingName,
        'brideName': profile.brideName,
        'groomName': profile.groomName,
        'weddingDate': profile.weddingDate.toIso8601String(),
        'location': profile.location,
        'theme': profile.theme,
        'expectedGuests': profile.expectedGuests,
        'budget': profile.budget,
        'notes': profile.notes,
        'createdAt': profile.createdAt?.toIso8601String() ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save wedding profile: $e');
    }
  }

  Future<WeddingProfile?> getWeddingProfile() async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('weddingProfiles').doc(userId).get();
      
      if (doc.exists) {
        return WeddingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wedding profile: $e');
    }
  }

  Future<bool> hasWeddingProfile() async {
    try {
      if (userId == null) return false;

      final doc = await _firestore.collection('weddingProfiles').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // TASK OPERATIONS
  Future<void> addTask(Task task) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add(task.toJson());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      if (userId == null || task.id == null) {
        throw Exception('User not authenticated or task ID missing');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update(task.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Stream<List<Task>> getTasksStream() {
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // GUEST OPERATIONS
  Future<void> addGuest(Guest guest) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('guests')
          .add(guest.toJson());
    } catch (e) {
      throw Exception('Failed to add guest: $e');
    }
  }

  Future<List<Guest>> getAllGuests() async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('guests')
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Guest.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch guests: $e');
    }
  }

  Future<void> updateGuest(Guest guest) async {
    try {
      if (userId == null || guest.id == null) {
        throw Exception('User not authenticated or guest ID missing');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('guests')
          .doc(guest.id)
          .update(guest.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update guest: $e');
    }
  }

  Future<void> deleteGuest(String guestId) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('guests')
          .doc(guestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete guest: $e');
    }
  }

  Stream<List<Guest>> getGuestsStream() {
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('guests')
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Guest.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // BUDGET OPERATIONS
  Future<void> addBudget(Budget budget) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .add(budget.toJson());
    } catch (e) {
      throw Exception('Failed to add budget: $e');
    }
  }

  Future<List<Budget>> getAllBudgets() async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .orderBy('category', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Budget.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch budgets: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      if (userId == null || budget.id == null) {
        throw Exception('User not authenticated or budget ID missing');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id)
          .update(budget.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  Stream<List<Budget>> getBudgetsStream() {
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('category', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Budget.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // DASHBOARD STATS
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();

      final guestsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('guests')
          .get();

      final budgetsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .get();

      final tasks = tasksSnapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final guests = guestsSnapshot.docs
          .map((doc) => Guest.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final budgets = budgetsSnapshot.docs
          .map((doc) => Budget.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final confirmedGuests = guests.where((g) => g.status == 'Confirmed').length;
      final totalBudget = budgets.fold<double>(0, (sum, b) => sum + b.amount);
      final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.spent);

      return {
        'completedTasks': completedTasks,
        'pendingTasks': tasks.length - completedTasks,
        'totalGuests': guests.length,
        'confirmedGuests': confirmedGuests,
        'totalBudget': totalBudget,
        'totalSpent': totalSpent,
      };
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  // USER OPERATIONS
  Future<void> saveUser(User user) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(userId).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<User?> getAppUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(userId).update({
        'name': user.name,
        'contact': user.contact,
        'userImage': user.userImage,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // VENDOR OPERATIONS
  Future<void> addVendor(Vendor vendor) async {
    try {
      await _firestore.collection('vendors').add(vendor.toMap());
    } catch (e) {
      throw Exception('Failed to add vendor: $e');
    }
  }

  Future<List<Vendor>> getVendors() async {
    try {
      final snapshot = await _firestore
          .collection('vendors')
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Vendor.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors: $e');
    }
  }

  Future<Vendor?> getVendorById(String vendorId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(vendorId).get();
      
      if (doc.exists) {
        return Vendor.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get vendor: $e');
    }
  }

  Future<List<Vendor>> getVendorsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('vendors')
          .where('category', isEqualTo: category)
          .orderBy('name', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Vendor.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors by category: $e');
    }
  }

  Future<void> updateVendor(String vendorId, Vendor vendor) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).update(vendor.toMap());
    } catch (e) {
      throw Exception('Failed to update vendor: $e');
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).delete();
    } catch (e) {
      throw Exception('Failed to delete vendor: $e');
    }
  }

  // VENDOR PRODUCT OPERATIONS
  Future<void> addProduct(VendorProduct product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<List<VendorProduct>> getProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('title', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => VendorProduct.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<VendorProduct>> getProductsByVendor(String vendorId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('vendorID', isEqualTo: vendorId)
          .orderBy('title', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => VendorProduct.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendor products: $e');
    }
  }

  Future<List<VendorProduct>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .orderBy('title', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => VendorProduct.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<void> updateProduct(String productId, VendorProduct product) async {
    try {
      await _firestore.collection('products').doc(productId).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // GALLERY OPERATIONS (SAVED UNDER USER DOCUMENT)
  Future<void> addGalleryItem(GalleryItem item) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gallery')
          .add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add gallery item: $e');
    }
  }

  Future<List<GalleryItem>> getGalleryItems() async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      print('📥 Fetching gallery items for user: $userId');
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gallery')
          .get();

      print('📦 Found ${snapshot.docs.length} gallery items');
      
      final items = snapshot.docs
          .map((doc) {
            print('📄 Document: ${doc.id}, Data: ${doc.data()}');
            return GalleryItem.fromMap(doc.data(), doc.id);
          })
          .toList();
      
      // Sort by createdAt in descending order
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      
      print('✅ Gallery items fetched and sorted: ${items.length} items');
      return items;
    } catch (e) {
      print('❌ Error fetching gallery items: $e');
      throw Exception('Failed to fetch gallery items: $e');
    }
  }

  Future<List<GalleryItem>> getGalleryByCategory(String category) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gallery')
          .where('category', isEqualTo: category)
          .get();

      final items = snapshot.docs
          .map((doc) => GalleryItem.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by createdAt in descending order
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      
      return items;
    } catch (e) {
      throw Exception('Failed to fetch gallery items by category: $e');
    }
  }

  Future<void> updateGalleryItem(String itemId, GalleryItem item) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gallery')
          .doc(itemId)
          .update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update gallery item: $e');
    }
  }

  Future<void> deleteGalleryItem(String itemId) async {
    try {
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gallery')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete gallery item: $e');
    }
  }
}
