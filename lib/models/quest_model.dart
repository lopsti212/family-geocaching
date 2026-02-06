enum QuestDifficulty {
  level1, // Direkter Ort wird angezeigt
  level2, // Umkreis ~100m
  level3, // Nur Kompass
}

enum QuestStatus {
  available,
  inProgress,
  completed,
  expired,
}

enum RewardType {
  screenTime,    // Handyzeit in Minuten
  pocketMoney,   // Taschengeld in Euro/Cent
  custom,        // Benutzerdefiniert (z.B. "Eis essen")
}

class Reward {
  final RewardType type;
  final double value; // Minuten oder Euro
  final String? customDescription;

  Reward({
    required this.type,
    required this.value,
    this.customDescription,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.custom,
      ),
      value: (json['value'] as num).toDouble(),
      customDescription: json['custom_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
      'custom_description': customDescription,
    };
  }

  String get displayText {
    switch (type) {
      case RewardType.screenTime:
        return '${value.toInt()} Minuten Handyzeit';
      case RewardType.pocketMoney:
        return '${value.toStringAsFixed(2)} €';
      case RewardType.custom:
        return customDescription ?? 'Belohnung';
    }
  }
}

class QuestModel {
  final String id;
  final String title;
  final String? description;
  final String createdBy; // Parent user ID
  final String? assignedTo; // Child user ID (null = alle Kinder)
  final String familyId;
  final double targetLatitude;
  final double targetLongitude;
  final QuestDifficulty difficulty;
  final Reward reward;
  final QuestStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? completedAt;
  final String? nfcTagId; // Optional NFC Tag
  final double? hintRadiusValue; // Einstellbarer Hinweisradius für Level 2

  QuestModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdBy,
    this.assignedTo,
    required this.familyId,
    required this.targetLatitude,
    required this.targetLongitude,
    required this.difficulty,
    required this.reward,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.completedAt,
    this.nfcTagId,
    this.hintRadiusValue,
  });

  // Radius in Metern basierend auf Schwierigkeit
  double get detectionRadius {
    switch (difficulty) {
      case QuestDifficulty.level1:
        return 20.0; // 20m - sehr genau
      case QuestDifficulty.level2:
        return 15.0; // 15m - muss im 100m Umkreis suchen
      case QuestDifficulty.level3:
        return 10.0; // 10m - nur Kompass, muss genau sein
    }
  }

  // Hinweisradius für Level 2
  double get hintRadius {
    return difficulty == QuestDifficulty.level2 ? (hintRadiusValue ?? 100.0) : 0.0;
  }

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      assignedTo: json['assigned_to'] as String?,
      familyId: json['family_id'] as String,
      targetLatitude: (json['target_latitude'] as num).toDouble(),
      targetLongitude: (json['target_longitude'] as num).toDouble(),
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuestDifficulty.level1,
      ),
      reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      status: QuestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QuestStatus.available,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      nfcTagId: json['nfc_tag_id'] as String?,
      hintRadiusValue: (json['hint_radius'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'family_id': familyId,
      'target_latitude': targetLatitude,
      'target_longitude': targetLongitude,
      'difficulty': difficulty.name,
      'reward': reward.toJson(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'nfc_tag_id': nfcTagId,
      'hint_radius': hintRadiusValue,
    };
  }

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? assignedTo,
    String? familyId,
    double? targetLatitude,
    double? targetLongitude,
    QuestDifficulty? difficulty,
    Reward? reward,
    QuestStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? completedAt,
    String? nfcTagId,
    double? hintRadiusValue,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      familyId: familyId ?? this.familyId,
      targetLatitude: targetLatitude ?? this.targetLatitude,
      targetLongitude: targetLongitude ?? this.targetLongitude,
      difficulty: difficulty ?? this.difficulty,
      reward: reward ?? this.reward,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt ?? this.completedAt,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      hintRadiusValue: hintRadiusValue ?? this.hintRadiusValue,
    );
  }

  String get difficultyDisplayText {
    switch (difficulty) {
      case QuestDifficulty.level1:
        return 'Stufe 1 - Einfach';
      case QuestDifficulty.level2:
        return 'Stufe 2 - Mittel';
      case QuestDifficulty.level3:
        return 'Stufe 3 - Schwer';
    }
  }
}
