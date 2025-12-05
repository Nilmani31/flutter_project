class WeddingProfile {
  String? id;
  String? userId;
  String weddingName;
  String brideName;
  String groomName;
  DateTime weddingDate;
  String location;
  String? theme;
  int? expectedGuests;
  double? budget;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  WeddingProfile({
    this.id,
    this.userId,
    required this.weddingName,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.location,
    this.theme,
    this.expectedGuests,
    this.budget,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'weddingName': weddingName,
      'brideName': brideName,
      'groomName': groomName,
      'weddingDate': weddingDate,
      'location': location,
      'theme': theme,
      'expectedGuests': expectedGuests,
      'budget': budget,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create from JSON from Firestore
  factory WeddingProfile.fromMap(Map<String, dynamic> map, String id) {
    return WeddingProfile(
      id: id,
      userId: map['userId'] as String?,
      weddingName: map['weddingName'] as String? ?? '',
      brideName: map['brideName'] as String? ?? '',
      groomName: map['groomName'] as String? ?? '',
      weddingDate: map['weddingDate'] is DateTime
          ? map['weddingDate'] as DateTime
          : DateTime.now(),
      location: map['location'] as String? ?? '',
      theme: map['theme'] as String?,
      expectedGuests: map['expectedGuests'] as int?,
      budget: (map['budget'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : null,
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : null,
    );
  }
}
