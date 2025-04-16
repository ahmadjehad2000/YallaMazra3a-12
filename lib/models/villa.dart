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
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      capacity: (map['capacity'] ?? 0).toInt(),
      hasPool: map['hasPool'] ?? false,
      hasWifi: map['hasWifi'] ?? false,
      hasBarbecue: map['hasBarbecue'] ?? false,
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
