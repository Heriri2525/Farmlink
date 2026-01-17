class Profile {
  final String userId;
  final String? name; // Can be null initially
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String userType; // 'buyer' or 'seller'

  Profile({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    required this.userType,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['user_id'] ?? json['id'], // Support both fallback during migration
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      userType: json['user_type'] ?? 'buyer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'user_type': userType,
    };
  }
}
