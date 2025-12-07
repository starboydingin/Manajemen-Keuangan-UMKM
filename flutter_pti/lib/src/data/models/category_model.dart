class CategoryModel {
  const CategoryModel({required this.id, required this.name, required this.type});

  final int id;
  final String name;
  final String type;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}
