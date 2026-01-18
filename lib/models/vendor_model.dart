class Vendor {
  String vendorID;
  String password;
  String name;
  String description;
  String contact;
  String category;
  DateTime? createdAt;
  DateTime? updatedAt;

  Vendor({
    required this.vendorID,
    required this.password,
    required this.name,
    required this.description,
    required this.contact,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  void vendorSignup() => print("Vendor $name signed up!");
  void vendorLogin() => print("Vendor $name logged in!");
  void vendorLogout() => print("Vendor $name logged out!");
  void vendorUpdateProfile(String newDesc) {
    description = newDesc;
    print("Vendor profile updated.");
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'vendorID': vendorID,
      'password': password,
      'name': name,
      'description': description,
      'contact': contact,
      'category': category,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from JSON from Firestore
  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      vendorID: map['vendorID'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      category: map['category'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString())
          : null,
    );
  }
}
