class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isGoogleSignIn;
  final List<String> favoriteVillas;
  final List<String> bookings;
  final bool isModerator;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.isGoogleSignIn,
    this.favoriteVillas = const [],
    this.bookings = const [],
    this.isModerator = false,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isGoogleSignIn: json['isGoogleSignIn'] ?? false,
      favoriteVillas: List<String>.from(json['favoriteVillas'] ?? []),
      bookings: List<String>.from(json['bookings'] ?? []),
      isModerator: json['isModerator'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
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
      'isModerator': isModerator,
      'isAdmin': isAdmin,
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
    bool? isModerator,
    bool? isAdmin,
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
      isModerator: isModerator ?? this.isModerator,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
