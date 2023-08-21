class Product {
  String? uid;
  String name;
  String description;
  String imageUrl; // 0 - not completed, 1 - completed

  Product({
    this.uid,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}
