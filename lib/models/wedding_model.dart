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
      'weddingDate': weddingDate.toIso8601String(),
      'location': location,
      'theme': theme,
      'expectedGuests': expectedGuests,
      'budget': budget,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON from Firestore
  factory WeddingProfile.fromMap(Map<String, dynamic> map, String id) {
    DateTime _parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing datetime: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return WeddingProfile(
      id: id,
      userId: map['userId'] as String?,
      weddingName: map['weddingName'] as String? ?? '',
      brideName: map['brideName'] as String? ?? '',
      groomName: map['groomName'] as String? ?? '',
      weddingDate: _parseDateTime(map['weddingDate']),
      location: map['location'] as String? ?? '',
      theme: map['theme'] as String?,
      expectedGuests: map['expectedGuests'] as int?,
      budget: (map['budget'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }
}
