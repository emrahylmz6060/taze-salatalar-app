class SaladModel {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String preparationTime;
  final int calories;
  final List<String> tags;
  final String imageUrl;

  SaladModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.preparationTime,
    required this.calories,
    required this.tags,
    required this.imageUrl,
  });

  factory SaladModel.fromJson(Map<String, dynamic> json) {
    return SaladModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      preparationTime: json['preparationTime'] as String,
      calories: json['calories'] as int,
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'steps': steps,
      'preparationTime': preparationTime,
      'calories': calories,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }
}
