class Formula {
  final String id;
  final String category;
  final String name;
  final String formula; // LaTeX string
  final String description;
  final String example; // LaTeX string

  Formula({
    required this.id,
    required this.category,
    required this.name,
    required this.formula,
    required this.description,
    required this.example,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      formula: json['formula'] as String,
      description: json['description'] as String,
      example: json['example'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'formula': formula,
      'description': description,
      'example': example,
    };
  }
}

