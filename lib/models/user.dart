class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isGoogleSignIn;
  final List<String> favoriteVillas;
  final List<String> bookings;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.isGoogleSignIn,
    this.favoriteVillas = const [],
    this.bookings = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isGoogleSignIn: json['isGoogleSignIn'],
      favoriteVillas: List<String>.from(json['favoriteVillas'] ?? []),
      bookings: List<String>.from(json['bookings'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'isGoogleSignIn': isGoogleSignIn,
      'favoriteVillas': favoriteVillas,
      'bookings': bookings,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    bool? isGoogleSignIn,
    List<String>? favoriteVillas,
    List<String>? bookings,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isGoogleSignIn: isGoogleSignIn ?? this.isGoogleSignIn,
      favoriteVillas: favoriteVillas ?? this.favoriteVillas,
      bookings: bookings ?? this.bookings,
    );
  }
}
