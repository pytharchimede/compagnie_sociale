class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String location;
  final bool isPremium;
  final int totalBookings;
  final double averageRating;
  final double totalSavings;
  final DateTime joinedDate;
  final List<String> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.location,
    this.isPremium = false,
    this.totalBookings = 0,
    this.averageRating = 0.0,
    this.totalSavings = 0.0,
    required this.joinedDate,
    this.preferences = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      location: json['location'] ?? '',
      isPremium: json['isPremium'] ?? false,
      totalBookings: json['totalBookings'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0.0).toDouble(),
      joinedDate: DateTime.parse(json['joinedDate'] ?? DateTime.now().toIso8601String()),
      preferences: List<String>.from(json['preferences'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'location': location,
      'isPremium': isPremium,
      'totalBookings': totalBookings,
      'averageRating': averageRating,
      'totalSavings': totalSavings,
      'joinedDate': joinedDate.toIso8601String(),
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? location,
    bool? isPremium,
    int? totalBookings,
    double? averageRating,
    double? totalSavings,
    DateTime? joinedDate,
    List<String>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      isPremium: isPremium ?? this.isPremium,
      totalBookings: totalBookings ?? this.totalBookings,
      averageRating: averageRating ?? this.averageRating,
      totalSavings: totalSavings ?? this.totalSavings,
      joinedDate: joinedDate ?? this.joinedDate,
      preferences: preferences ?? this.preferences,
    );
  }
}
