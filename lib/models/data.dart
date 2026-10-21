class User {
  String username;
  String password;
  String nama;

  User({required this.username, required this.password, required this.nama});
}

User user1 = User(
  username: 'budi123',
  password: 'password123',
  nama: 'Budi Santoso',
);

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
  });

  // factory constructor untuk pembuatan instance Product dari JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      image: json['images'][0],
    );
  }
}
