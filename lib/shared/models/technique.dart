class Belt {
  const Belt({required this.id, required this.color, required this.order});

  final int id;
  final String color;
  final int order;

  factory Belt.fromJson(Map<String, dynamic> json) => Belt(
        id: json['id'] as int,
        color: json['color'] as String,
        order: json['order'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Belt && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TechniqueCategory {
  const TechniqueCategory({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description;

  factory TechniqueCategory.fromJson(Map<String, dynamic> json) => TechniqueCategory(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TechniqueCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TechniqueVariation {
  const TechniqueVariation({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description;

  factory TechniqueVariation.fromJson(Map<String, dynamic> json) => TechniqueVariation(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TechniqueVariation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TechniqueFlow {
  const TechniqueFlow({required this.id, required this.toTechnique, this.description});

  final int id;
  final String toTechnique;
  final String? description;

  factory TechniqueFlow.fromJson(Map<String, dynamic> json) => TechniqueFlow(
        id: json['id'] as int,
        toTechnique: json['to_technique'] as String,
        description: json['description'] as String?,
      );
}

class Technique {
  const Technique({
    required this.id,
    required this.name,
    this.description,
    this.difficulty,
    required this.minBelt,
    required this.categories,
    required this.variations,
    required this.leadsTo,
  });

  final int id;
  final String name;
  final String? description;
  final int? difficulty;
  final String minBelt;
  final List<TechniqueCategory> categories;
  final List<TechniqueVariation> variations;
  final List<TechniqueFlow> leadsTo;

  factory Technique.fromJson(Map<String, dynamic> json) => Technique(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        difficulty: json['difficulty'] as int?,
        minBelt: json['min_belt'] as String? ?? 'white',
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => TechniqueCategory.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        variations: (json['variations'] as List<dynamic>?)
                ?.map((e) => TechniqueVariation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        leadsTo: (json['leads_to'] as List<dynamic>?)
                ?.map((e) => TechniqueFlow.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Technique && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
