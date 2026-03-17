class Academy {
  const Academy({
    required this.id,
    required this.name,
    this.city,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? city;
  final DateTime createdAt;

  factory Academy.fromJson(Map<String, dynamic> json) => Academy(
        id: json['id'] as int,
        name: json['name'] as String,
        city: json['city'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (city != null) 'city': city,
        'created_at': createdAt.toIso8601String(),
      };

  Academy copyWith({int? id, String? name, String? city, DateTime? createdAt}) =>
      Academy(
        id: id ?? this.id,
        name: name ?? this.name,
        city: city ?? this.city,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Academy && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
