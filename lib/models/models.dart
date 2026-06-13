// ─── Leader Model ───────────────────────────────────────────────────────────
class Leader {
  final int? id;
  final int levelId;
  final String levelType; // 'district', 'division', 'ward'
  final int positionIndex; // 0-5
  final String fullName;
  final String phoneNumber;
  final String emailAddress;
  final String? photoPath;

  const Leader({
    this.id,
    required this.levelId,
    required this.levelType,
    required this.positionIndex,
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
    this.photoPath,
  });

  static const List<String> positions = [
    'Mwenyekiti',
    'Katibu',
    'Katibu wa Hamasa',
    'Katibu wa Uchumi',
    'Katibu wa Maadili, Nidhamu na Malezi',
    'Katibu wa Itifaki, Ulinzi na Usalama',
  ];

  String get positionName => positions[positionIndex];

  Leader copyWith({
    int? id, int? levelId, String? levelType, int? positionIndex,
    String? fullName, String? phoneNumber, String? emailAddress, String? photoPath,
  }) {
    return Leader(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      levelType: levelType ?? this.levelType,
      positionIndex: positionIndex ?? this.positionIndex,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'level_id': levelId, 'level_type': levelType,
    'position_index': positionIndex, 'full_name': fullName,
    'phone_number': phoneNumber, 'email_address': emailAddress, 'photo_path': photoPath,
  };

  factory Leader.fromMap(Map<String, dynamic> map) => Leader(
    id: map['id'], levelId: map['level_id'], levelType: map['level_type'],
    positionIndex: map['position_index'], fullName: map['full_name'] ?? '',
    phoneNumber: map['phone_number'] ?? '', emailAddress: map['email_address'] ?? '',
    photoPath: map['photo_path'],
  );

  bool get isEmpty => fullName.isEmpty && phoneNumber.isEmpty && emailAddress.isEmpty;
}

// ─── Division Model ──────────────────────────────────────────────────────────
class Division {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Division({this.id, required this.name, this.description, required this.createdAt});

  Division copyWith({int? id, String? name, String? description, DateTime? createdAt}) {
    return Division(id: id ?? this.id, name: name ?? this.name,
      description: description ?? this.description, createdAt: createdAt ?? this.createdAt);
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'description': description,
    'created_at': createdAt.toIso8601String(),
  };

  factory Division.fromMap(Map<String, dynamic> map) => Division(
    id: map['id'], name: map['name'], description: map['description'],
    createdAt: DateTime.parse(map['created_at']),
  );
}

// ─── Ward Model ───────────────────────────────────────────────────────────────
class Ward {
  final int? id;
  final int divisionId;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Ward({this.id, required this.divisionId, required this.name,
    this.description, required this.createdAt});

  Ward copyWith({int? id, int? divisionId, String? name, String? description, DateTime? createdAt}) {
    return Ward(id: id ?? this.id, divisionId: divisionId ?? this.divisionId,
      name: name ?? this.name, description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt);
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'division_id': divisionId, 'name': name,
    'description': description, 'created_at': createdAt.toIso8601String(),
  };

  factory Ward.fromMap(Map<String, dynamic> map) => Ward(
    id: map['id'], divisionId: map['division_id'], name: map['name'],
    description: map['description'], createdAt: DateTime.parse(map['created_at']),
  );
}

// ─── Search Result Model ──────────────────────────────────────────────────────
class SearchResult {
  final Leader leader;
  final String levelName;
  final String? divisionName;

  const SearchResult({required this.leader, required this.levelName, this.divisionName});
}
