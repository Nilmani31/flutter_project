class Guest {
  final String? id;  // Changed from int? to String? for Firebase
  final String name;
  final String email;
  final String phone;
  final String status; // 'Confirmed', 'Pending', 'Declined'
  final bool hasPlus1;
  final String? notes;
  final String? dietaryRestrictions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Guest({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.hasPlus1 = false,
    this.notes,
    this.dietaryRestrictions,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Guest to JSON for API/Firebase
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'status': status,
    'hasPlus1': hasPlus1,
    'notes': notes,
    'dietaryRestrictions': dietaryRestrictions,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create Guest from JSON
  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
    id: json['id'] as String?,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    status: json['status'] as String,
    hasPlus1: (json['hasPlus1'] as bool?) ?? false,
    notes: json['notes'] as String?,
    dietaryRestrictions: json['dietaryRestrictions'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );

  // Convert to Map for database (SQLite)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'status': status,
    'hasPlus1': hasPlus1 ? 1 : 0,
    'notes': notes,
    'dietaryRestrictions': dietaryRestrictions,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create from database Map (SQLite)
  factory Guest.fromMap(Map<String, dynamic> map) => Guest(
    id: map['id'] as String?,
    name: map['name'] as String,
    email: map['email'] as String,
    phone: map['phone'] as String,
    status: map['status'] as String,
    hasPlus1: (map['hasPlus1'] as int?) == 1,
    notes: map['notes'] as String?,
    dietaryRestrictions: map['dietaryRestrictions'] as String?,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
  );

  // Copy with modifications
  Guest copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    bool? hasPlus1,
    String? notes,
    String? dietaryRestrictions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
    Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      hasPlus1: hasPlus1 ?? this.hasPlus1,
      notes: notes ?? this.notes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
}
