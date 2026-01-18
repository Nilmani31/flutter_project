class User {
  String? id; // Firebase document ID
  String userID; // Username
  String password;
  String name;
  String contact;
  String userImage;
  String email;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String> weddingIds; // List of wedding IDs this user has planned

  User({
    this.id,
    required this.userID,
    required this.password,
    required this.name,
    required this.contact,
    required this.userImage,
    required this.email,
    this.createdAt,
    this.updatedAt,
    this.weddingIds = const [],
  });

  void userSignup() => print("$name signed up!");
  void userLogin() => print("$name logged in!");
  void userLogout() => print("$name logged out!");
  void userUpdateProfile(String newName) {
    name = newName;
    print("Profile updated: $name");
  }

  // Add wedding to user's wedding list
  void addWeddingToUser(String weddingId) {
    if (!weddingIds.contains(weddingId)) {
      weddingIds.add(weddingId);
      print("Wedding $weddingId added to user $name");
    }
  }

  // Remove wedding from user's wedding list
  void removeWeddingFromUser(String weddingId) {
    if (weddingIds.contains(weddingId)) {
      weddingIds.remove(weddingId);
      print("Wedding $weddingId removed from user $name");
    }
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'password': password,
      'name': name,
      'contact': contact,
      'userImage': userImage,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'weddingIds': weddingIds,
    };
  }

  // Create from JSON from Firestore
  factory User.fromMap(Map<String, dynamic> map, String docId) {
    return User(
      id: docId,
      userID: map['userID'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      userImage: map['userImage'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'].toString())
          : null,
      weddingIds: List<String>.from(map['weddingIds'] ?? []),
    );
  }
}
