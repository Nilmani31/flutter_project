import 'package:flutter/material.dart';
import '../models/vendor_product_model.dart';
import '../services/firebase_service.dart';

class VendorProductProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<VendorProduct> _products = [];
  bool _loadingProducts = false;
  String _productError = '';

  // Getters
  List<VendorProduct> get products => _products;
  bool get loadingProducts => _loadingProducts;
  String get productError => _productError;

  // Fetch all products
  Future<void> fetchProducts() async {
    _loadingProducts = true;
    _productError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _products = await _firebaseService.getProducts();
      _productError = '';
    } catch (e) {
      _productError = 'Failed to fetch products: $e';
      print('Error: $_productError');
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  // Fetch products by vendor
  Future<void> fetchProductsByVendor(String vendorID) async {
    _loadingProducts = true;
    _productError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _products = await _firebaseService.getProductsByVendor(vendorID);
      _productError = '';
    } catch (e) {
      _productError = 'Failed to fetch vendor products: $e';
      print('Error: $_productError');
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    _loadingProducts = true;
    _productError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _products = await _firebaseService.getProductsByCategory(category);
      _productError = '';
    } catch (e) {
      _productError = 'Failed to fetch products by category: $e';
      print('Error: $_productError');
    } finally {
      _loadingProducts = false;
      notifyListeners();
    }
  }

  // Add product
  Future<void> addProduct(VendorProduct product) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.addProduct(product);
      _products.add(product);
      _productError = '';
      notifyListeners();
    } catch (e) {
      _productError = 'Failed to add product: $e';
      print('Error: $_productError');
    }
  }

  // Update product
  Future<void> updateProduct(String productID, VendorProduct product) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.updateProduct(productID, product);
      final index = _products.indexWhere((p) => p.id == productID);
      if (index != -1) {
        _products[index] = product;
      }
      _productError = '';
      notifyListeners();
    } catch (e) {
      _productError = 'Failed to update product: $e';
      print('Error: $_productError');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productID) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.deleteProduct(productID);
      _products.removeWhere((p) => p.id == productID);
      _productError = '';
      notifyListeners();
    } catch (e) {
      _productError = 'Failed to delete product: $e';
      print('Error: $_productError');
    }
  }

  // Clear error
  void clearError() {
    _productError = '';
    notifyListeners();
  }
}
