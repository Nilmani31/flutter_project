class Budget {
  final String? id;  // Changed from int? to String? for Firebase
  final String category;
  final double amount;
  final double spent;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    this.spent = 0,
    this.notes = '',
    required this.createdAt,
    this.updatedAt,
  });

  double get remaining => amount - spent;
  double get percentageUsed => (spent / amount) * 100;

  Map<String, dynamic> toJson() => {
    'category': category,
    'amount': amount,
    'spent': spent,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'] as String?,
    category: json['category'] as String,
    amount: (json['amount'] as num).toDouble(),
    spent: (json['spent'] as num?)?.toDouble() ?? 0,
    notes: json['notes'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'amount': amount,
    'spent': spent,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
    id: map['id'] as String?,
    category: map['category'] as String,
    amount: (map['amount'] as num).toDouble(),
    spent: (map['spent'] as num?)?.toDouble() ?? 0,
    notes: map['notes'] as String? ?? '',
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
  );

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    double? spent,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
    Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
}
