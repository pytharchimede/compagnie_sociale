class Companion {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String image;
  final double rating;
  final double price;
  final int reviews;
  final bool verified;
  final bool available;
  final List<String> languages;
  final String experience;
  final String category;
  final String description;
  final String phone;

  Companion({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.image,
    required this.rating,
    required this.price,
    required this.reviews,
    required this.verified,
    required this.available,
    required this.languages,
    required this.experience,
    required this.category,
    required this.description,
    required this.phone,
  });

  factory Companion.fromJson(Map<String, dynamic> json) {
    return Companion(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      verified: json['verified'] ?? false,
      available: json['available'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
      experience: json['experience'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'location': location,
      'image': image,
      'rating': rating,
      'price': price,
      'reviews': reviews,
      'verified': verified,
      'available': available,
      'languages': languages,
      'experience': experience,
      'category': category,
      'description': description,
      'phone': phone,
    };
  }
}
