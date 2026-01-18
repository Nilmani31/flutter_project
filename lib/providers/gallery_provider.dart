import 'package:flutter/material.dart';
import '../models/gallery_item_model.dart';
import '../services/firebase_service.dart';

class GalleryProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<GalleryItem> _galleryItems = [];
  bool _loadingGallery = false;
  String _galleryError = '';

  // Getters
  List<GalleryItem> get galleryItems => _galleryItems;
  bool get loadingGallery => _loadingGallery;
  String get galleryError => _galleryError;
  int get galleryItemCount => _galleryItems.length;

  // Fetch all gallery items
  Future<void> fetchGalleryItems() async {
    _loadingGallery = true;
    _galleryError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _galleryItems = await _firebaseService.getGalleryItems();
      _galleryError = '';
    } catch (e) {
      _galleryError = 'Failed to fetch gallery items: $e';
      print('Error: $_galleryError');
    } finally {
      _loadingGallery = false;
      notifyListeners();
    }
  }

  // Fetch gallery items by category
  Future<void> fetchGalleryByCategory(String category) async {
    _loadingGallery = true;
    _galleryError = '';
    notifyListeners();

    try {
      // TODO: Implement Firebase integration
      _galleryItems = await _firebaseService.getGalleryByCategory(category);
      _galleryError = '';
    } catch (e) {
      _galleryError = 'Failed to fetch gallery items: $e';
      print('Error: $_galleryError');
    } finally {
      _loadingGallery = false;
      notifyListeners();
    }
  }

  // Add gallery item
  Future<void> addGalleryItem(GalleryItem item) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.addGalleryItem(item);
      _galleryItems.add(item);
      _galleryError = '';
      notifyListeners();
    } catch (e) {
      _galleryError = 'Failed to add gallery item: $e';
      print('Error: $_galleryError');
    }
  }

  // Update gallery item
  Future<void> updateGalleryItem(String itemID, GalleryItem item) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.updateGalleryItem(itemID, item);
      final index = _galleryItems.indexWhere((g) => g.id == itemID);
      if (index != -1) {
        _galleryItems[index] = item;
      }
      _galleryError = '';
      notifyListeners();
    } catch (e) {
      _galleryError = 'Failed to update gallery item: $e';
      print('Error: $_galleryError');
    }
  }

  // Delete gallery item
  Future<void> deleteGalleryItem(String itemID) async {
    try {
      // TODO: Implement Firebase integration
      await _firebaseService.deleteGalleryItem(itemID);
      _galleryItems.removeWhere((g) => g.id == itemID);
      _galleryError = '';
      notifyListeners();
    } catch (e) {
      _galleryError = 'Failed to delete gallery item: $e';
      print('Error: $_galleryError');
    }
  }

  // Clear error
  void clearError() {
    _galleryError = '';
    notifyListeners();
  }
}
