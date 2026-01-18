import 'package:flutter/material.dart';
import '../models/vendor_model.dart';
import '../services/firebase_service.dart';

class VendorProvider extends ChangeNotifier {
  // final FirebaseService _firebaseService = FirebaseService();
  final FirebaseService _firebaseService = FirebaseService();
  List<Vendor> _vendors = [];
  bool _loadingVendors = false;
  String _vendorError = '';
  Vendor? _currentVendor;

  // Getters
  List<Vendor> get vendors => _vendors;
  bool get loadingVendors => _loadingVendors;
  String get vendorError => _vendorError;
  Vendor? get currentVendor => _currentVendor;

  // Fetch all vendors
  Future<void> fetchVendors() async {
    _loadingVendors = true;
    _vendorError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _vendors = await _firebaseService.getVendors();
      _vendorError = '';
    } catch (e) {
      _vendorError = 'Failed to fetch vendors: $e';
      print('Error: $_vendorError');
    } finally {
      _loadingVendors = false;
      notifyListeners();
    }
  }

  // Fetch vendor by ID
  Future<void> fetchVendorById(String vendorID) async {
    _loadingVendors = true;
    _vendorError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _currentVendor = await _firebaseService.getVendorById(vendorID);
      _vendorError = '';
    } catch (e) {
      _vendorError = 'Failed to fetch vendor: $e';
      print('Error: $_vendorError');
    } finally {
      _loadingVendors = false;
      notifyListeners();
    }
  }

  // Add vendor
  Future<void> addVendor(Vendor vendor) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.addVendor(vendor);
      _vendors.add(vendor);
      _vendorError = '';
      notifyListeners();
    } catch (e) {
      _vendorError = 'Failed to add vendor: $e';
      print('Error: $_vendorError');
    }
  }

  // Update vendor
  Future<void> updateVendor(String vendorID, Vendor vendor) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.updateVendor(vendorID, vendor);
      final index = _vendors.indexWhere((v) => v.vendorID == vendorID);
      if (index != -1) {
        _vendors[index] = vendor;
      }
      _vendorError = '';
      notifyListeners();
    } catch (e) {
      _vendorError = 'Failed to update vendor: $e';
      print('Error: $_vendorError');
    }
  }

  // Delete vendor
  Future<void> deleteVendor(String vendorID) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.deleteVendor(vendorID);
      _vendors.removeWhere((v) => v.vendorID == vendorID);
      _vendorError = '';
      notifyListeners();
    } catch (e) {
      _vendorError = 'Failed to delete vendor: $e';
      print('Error: $_vendorError');
    }
  }

  // Fetch vendors by category
  Future<void> fetchVendorsByCategory(String category) async {
    _loadingVendors = true;
    _vendorError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _vendors = await _firebaseService.getVendorsByCategory(category);
      _vendorError = '';
    } catch (e) {
      _vendorError = 'Failed to fetch vendors by category: $e';
      print('Error: $_vendorError');
    } finally {
      _loadingVendors = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _vendorError = '';
    notifyListeners();
  }
}
