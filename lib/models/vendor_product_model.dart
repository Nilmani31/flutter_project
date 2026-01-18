class VendorProduct {
  String? id;
  String vendorID;
  String category;
  String title;
  String description;
  String image;
  double price;
  int quantity;
  bool isAvailable;
  DateTime? createdAt;
  DateTime? updatedAt;

  VendorProduct({
    this.id,
    required this.vendorID,
    required this.category,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.quantity = 0,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  void addProduct() => print("Product added: $title");
  void editProduct(String newTitle) => title = newTitle;
  void deleteProduct() => print("Product $title deleted.");
  void viewProduct() => print("Product: $title - \$$price");

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'vendorID': vendorID,
      'category': category,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from JSON from Firestore
  factory VendorProduct.fromMap(Map<String, dynamic> map, String docId) {
    return VendorProduct(
      id: docId,
      vendorID: map['vendorID'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString())
          : null,
    );
  }
}
