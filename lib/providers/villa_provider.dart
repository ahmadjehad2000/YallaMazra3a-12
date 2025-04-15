import 'package:flutter/material.dart';
import '../models/villa.dart';
import '../utils/mock_data.dart';

class VillaProvider extends ChangeNotifier {
  List<Villa> _villas = [];
  List<Villa> _filteredVillas = [];
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  Map<String, bool> _filters = {
    'مسبح': false,
    'واي فاي': false,
    'شواء': false,
  };

  List<Villa> get villas => _villas;
  List<Villa> get filteredVillas => _filteredVillas;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  Map<String, bool> get filters => _filters;

  VillaProvider() {
    _loadVillas();
  }

  void _loadVillas() {
    // Load mock villas from mock_data.dart
    _villas = MockData.getVillas();
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void toggleFilter(String filter) {
    _filters[filter] = !(_filters[filter] ?? false);
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _filters.updateAll((key, value) => false);
    _selectedCategory = 'الكل';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredVillas = _villas.where((villa) {
      // Apply search query filter
      bool matchesSearch = _searchQuery.isEmpty ||
          villa.title.contains(_searchQuery) ||
          villa.location.contains(_searchQuery) ||
          villa.description.contains(_searchQuery);

      // Apply category filter
      bool matchesCategory = _selectedCategory == 'الكل' ||
          (_selectedCategory == 'الأعلى تقييماً' && villa.rating >= 4.5) ||
          (_selectedCategory == 'الأكثر طلباً' && villa.capacity >= 8) ||
          (_selectedCategory == 'قريب منك' && villa.location.contains('الرياض'));

      // Apply amenity filters
      bool matchesFilters = true;
      if (_filters['مسبح'] == true && !villa.hasPool) {
        matchesFilters = false;
      }
      if (_filters['واي فاي'] == true && !villa.hasWifi) {
        matchesFilters = false;
      }
      if (_filters['شواء'] == true && !villa.hasBarbecue) {
        matchesFilters = false;
      }

      return matchesSearch && matchesCategory && matchesFilters;
    }).toList();

    // Sort by rating if category is "الأعلى تقييماً"
    if (_selectedCategory == 'الأعلى تقييماً') {
      _filteredVillas.sort((a, b) => b.rating.compareTo(a.rating));
    }

    notifyListeners();
  }

  List<Villa> getTopRatedVillas() {
    List<Villa> topRated = List.from(_villas);
    topRated.sort((a, b) => b.rating.compareTo(a.rating));
    return topRated.take(5).toList();
  }

  List<Villa> getMostPopularVillas() {
    List<Villa> popular = _villas.where((villa) => villa.capacity >= 8).toList();
    return popular.take(5).toList();
  }

  List<Villa> getNearbyVillas(String location) {
    List<Villa> nearby = _villas.where((villa) => 
      villa.location.contains(location)
    ).toList();
    return nearby.take(5).toList();
  }

  Villa getVillaById(String id) {
    return _villas.firstWhere((villa) => villa.id == id, 
      orElse: () => throw Exception('Villa not found'));
  }
}
