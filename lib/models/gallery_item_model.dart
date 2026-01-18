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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
          ? DateTime.parse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString())
          : null,
    );
  }
}
