class FamilyMember {
  final int? id;
  final String name;
  final String relationship;
  final DateTime? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FamilyMember({
    this.id,
    required this.name,
    required this.relationship,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'birthday': dateOfBirth?.toIso8601String(),
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as int?,
      name: map['name'] as String,
      relationship: map['relationship'] as String,
      dateOfBirth: map['birthday'] != null ? DateTime.parse(map['birthday'] as String) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
    );
  }
}
