// lib/models/villa.dart

class Villa {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String description;
  final double price;
  final double rating;
  final int capacity;
  final bool hasPool;
  final bool hasWifi;
  final bool hasBarbecue;

  Villa({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.rating,
    required this.capacity,
    required this.hasPool,
    required this.hasWifi,
    required this.hasBarbecue,
  });

  factory Villa.fromMap(Map<String, dynamic> map) {
    return Villa(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      location: map['location'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : map['price'] as double? ?? 0.0,
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : map['rating'] as double? ?? 0.0,
      capacity: map['capacity'] as int? ?? 0,
      hasPool: map['hasPool'] as bool? ?? false,
      hasWifi: map['hasWifi'] as bool? ?? false,
      hasBarbecue: map['hasBarbecue'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'description': description,
      'price': price,
      'rating': rating,
      'capacity': capacity,
      'hasPool': hasPool,
      'hasWifi': hasWifi,
      'hasBarbecue': hasBarbecue,
    };
  }
}