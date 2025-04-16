import '../models/villa.dart';

final List<Villa> mockVillas = [
  Villa(
    id: '1',
    name: 'مزرعة الأحلام',
    location: 'عمان',
    imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
    description: 'مزرعة هادئة بإطلالة جميلة وخدمات متكاملة.',
    price: 90.0,
    rating: 4.8,
    capacity: 10,
    hasPool: true,
    hasWifi: true,
    hasBarbecue: true,
  ),
  Villa(
    id: '2',
    name: 'استراحة النخيل',
    location: 'الزرقاء',
    imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80',
    description: 'استراحة مميزة للعائلات وسط النخيل.',
    price: 75.0,
    rating: 4.6,
    capacity: 8,
    hasPool: false,
    hasWifi: true,
    hasBarbecue: true,
  ),
];
