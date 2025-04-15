class Villa {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final double rating;
  final int bedroomsCount;
  final int bathroomsCount;
  final int capacity;
  final bool hasPool;
  final bool hasWifi;
  final bool hasBarbecue;
  final List<String> amenities;
  final String ownerName;
  final String ownerPhone;

  Villa({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.rating,
    required this.bedroomsCount,
    required this.bathroomsCount,
    required this.capacity,
    required this.hasPool,
    required this.hasWifi,
    required this.hasBarbecue,
    required this.amenities,
    required this.ownerName,
    required this.ownerPhone,
  });

  factory Villa.fromJson(Map<String, dynamic> json) {
    return Villa(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      location: json['location'],
      images: List<String>.from(json['images']),
      rating: json['rating'].toDouble(),
      bedroomsCount: json['bedroomsCount'],
      bathroomsCount: json['bathroomsCount'],
      capacity: json['capacity'],
      hasPool: json['hasPool'],
      hasWifi: json['hasWifi'],
      hasBarbecue: json['hasBarbecue'],
      amenities: List<String>.from(json['amenities']),
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'images': images,
      'rating': rating,
      'bedroomsCount': bedroomsCount,
      'bathroomsCount': bathroomsCount,
      'capacity': capacity,
      'hasPool': hasPool,
      'hasWifi': hasWifi,
      'hasBarbecue': hasBarbecue,
      'amenities': amenities,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
    };
  }
}
