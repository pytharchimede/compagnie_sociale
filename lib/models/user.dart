class User {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? location;
  final String? bio;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final int totalBookings;
  final double averageRating;
  final double totalSavings;
  final List<String> preferences;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.location,
    this.bio,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.totalBookings = 0,
    this.averageRating = 0.0,
    this.totalSavings = 0.0,
    this.preferences = const [],
  });

  // Getters pour compatibilité avec l'ancien modèle
  String get name => fullName;
  DateTime get joinedDate => createdAt;
  String? get profileImage => avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'] ?? json['profileImage'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      location: json['location'],
      bio: json['bio'],
      isVerified: json['isVerified'] == 1 || json['isVerified'] == true,
      createdAt: DateTime.parse(json['createdAt'] ??
          json['joinedDate'] ??
          DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isPremium: json['isPremium'] == 1 || json['isPremium'] == true,
      totalBookings: json['totalBookings'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0.0).toDouble(),
      preferences: List<String>.from(json['preferences'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'location': location,
      'bio': bio,
      'isVerified': isVerified ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isPremium': isPremium ? 1 : 0,
      'totalBookings': totalBookings,
      'averageRating': averageRating,
      'totalSavings': totalSavings,
      'preferences': preferences,
    };
  }

  // Version pour l'API (sans le mot de passe)
  Map<String, dynamic> toApiJson() {
    final json = toJson();
    json.remove('password');
    return json;
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? location,
    String? bio,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    int? totalBookings,
    double? averageRating,
    double? totalSavings,
    List<String>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      totalBookings: totalBookings ?? this.totalBookings,
      averageRating: averageRating ?? this.averageRating,
      totalSavings: totalSavings ?? this.totalSavings,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
