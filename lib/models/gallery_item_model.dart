import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  String? id;
  String title;
  String description;
  String url;
  String? category;
  DateTime? createdAt;
  DateTime? updatedAt;

  GalleryItem({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  void addItem() => print("Gallery item added: $title");
  void editItem(String newTitle, String newdescription, String newurl) {
    title = newTitle;
    description = newdescription;
    url = newurl;
  }
  void deleteItem() => print("Item $title deleted.");
  void viewItem() => print("Gallery: $title - $url");

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON from Firestore
  factory GalleryItem.fromMap(Map<String, dynamic> map, String docId) {
    return GalleryItem(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      url: map['url'] ?? '',
      category: map['category'],
      createdAt: map['createdAt'] != null 
          ? _parseDateTime(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null 
          ? _parseDateTime(map['updatedAt'])
          : null,
    );
  }

  // Helper method to parse DateTime from Firestore Timestamp or string
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      // If it's a Firestore Timestamp object (from cloud_firestore)
      if (value is Timestamp) {
        return value.toDate();
      }
      // If it's a string (ISO8601)
      if (value is String) {
        return DateTime.parse(value);
      }
      // Fallback: try to parse string representation
      print('Unknown datetime type: ${value.runtimeType}, value: $value');
    } catch (e) {
      print('❌ Error parsing date: $e, value: $value');
    }
    return null;
  }
}
