import 'package:flutter/material.dart';
import '../models/villa.dart';
import '../services/villa_service.dart';

class VillaProvider extends ChangeNotifier {
  List<Villa> _villas = [];
  List<Villa> _filteredVillas = [];

  String _searchQuery = '';
  String _selectedCategory = '';
  final Map<String, bool> _filters = {
    'مسبح': false,
    'واي فاي': false,
    'شواء': false,
  };

  VillaProvider() {
    loadVillasFromFirebase();
  }

  Future<void> loadVillasFromFirebase() async {
    try {
      _villas = await VillaService().fetchVillas();
      _filteredVillas = List.from(_villas);
      notifyListeners();
    } catch (e) {
      print('Error loading villas: $e');
    }
  }

  List<Villa> get villas => _filteredVillas;

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void toggleFilter(String key) {
    _filters[key] = !_filters[key]!;
    _applyFilters();
  }

  void resetFilters() {
    _filters.updateAll((_, __) => false);
    _searchQuery = '';
    _selectedCategory = '';
    _applyFilters();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredVillas = _villas.where((villa) {
      if (_searchQuery.isNotEmpty &&
          !villa.name.contains(_searchQuery) &&
          !villa.location.contains(_searchQuery)) {
        return false;
      }

      if (_selectedCategory == 'الأعلى تقييماً' && villa.rating < 4.5) return false;
      if (_selectedCategory == 'الأكثر طلباً' && villa.capacity < 8) return false;

      if (_filters['مسبح'] == true && !villa.hasPool) return false;
      if (_filters['واي فاي'] == true && !villa.hasWifi) return false;
      if (_filters['شواء'] == true && !villa.hasBarbecue) return false;

      return true;
    }).toList();

    _filteredVillas.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  List<Villa> getTopRatedVillas() =>
      _villas.where((v) => v.rating >= 4.5).toList();

  List<Villa> getMostPopularVillas() =>
      _villas.where((v) => v.capacity >= 8).toList();

  List<Villa> getNearbyVillas(String city) =>
      _villas.where((v) => v.location == city).toList();

  Villa? getVillaById(String id) =>
      _villas.firstWhere((v) => v.id == id, orElse: () => _villas.first);

  Map<String, bool> get filters => _filters;
}
