class Plant {
  final String id;
  final String name;
  final String? imageUrl;
  final String emoji;
  final int wateringFrequencyDays;
  final DateTime lastWateredDate;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plant({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.emoji,
    required this.wateringFrequencyDays,
    required this.lastWateredDate,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool needsWatering() {
    final daysSinceWatered = DateTime.now().difference(lastWateredDate).inDays;
    return daysSinceWatered >= wateringFrequencyDays;
  }

  int daysUntilNextWatering() {
    final daysSinceWatered = DateTime.now().difference(lastWateredDate).inDays;
    return wateringFrequencyDays - daysSinceWatered;
  }

  int daysOverdue() {
    final daysUntil = daysUntilNextWatering();
    return daysUntil < 0 ? -daysUntil : 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'emoji': emoji,
    'wateringFrequencyDays': wateringFrequencyDays,
    'lastWateredDate': lastWateredDate.toIso8601String(),
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['imageUrl'] as String?,
    emoji: json['emoji'] as String,
    wateringFrequencyDays: json['wateringFrequencyDays'] as int,
    lastWateredDate: DateTime.parse(json['lastWateredDate'] as String),
    userId: json['userId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Plant copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? emoji,
    int? wateringFrequencyDays,
    DateTime? lastWateredDate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Plant(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    emoji: emoji ?? this.emoji,
    wateringFrequencyDays: wateringFrequencyDays ?? this.wateringFrequencyDays,
    lastWateredDate: lastWateredDate ?? this.lastWateredDate,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
