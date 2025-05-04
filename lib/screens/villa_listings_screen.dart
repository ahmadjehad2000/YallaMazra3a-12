import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/villa_provider.dart';
import '../models/villa.dart';
import 'villa_detail_screen.dart';

class VillaListingsScreen extends StatefulWidget {
  const VillaListingsScreen({Key? key}) : super(key: key);

  @override
  _VillaListingsScreenState createState() => _VillaListingsScreenState();
}

class _VillaListingsScreenState extends State<VillaListingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLocation;
  int _selectedPriceIndex = 0;

  final List<String> _locations = [
    'عمان', 'إربد', 'العقبة', 'الزرقاء', 'مأدبا', 'الكرك', 'المفرق'
  ];
  final List<Map<String, dynamic>> _priceOptions = [
    {'label': 'كل الأسعار', 'min': 0.0, 'max': null},
    {'label': 'أقل من 50 JD', 'min': 0.0, 'max': 50.0},
    {'label': '50 - 100 JD', 'min': 50.0, 'max': 100.0},
    {'label': '100 - 200 JD', 'min': 100.0, 'max': 200.0},
    {'label': '200 - 500 JD', 'min': 200.0, 'max': 500.0},
    {'label': '500 JD فما فوق', 'min': 500.0, 'max': null},
  ];

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedLocation = null;
      _selectedPriceIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المزارع'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: Consumer<VillaProvider>(
        builder: (context, provider, _) {
          final allVillas = provider.villas;
          if (allVillas.isEmpty) {
            return const Center(child: Text('لا توجد فيلات'));
          }

          final query = _searchController.text.trim().toLowerCase();
          final priceOpt = _priceOptions[_selectedPriceIndex];

          final filtered = allVillas.where((v) {
            final matchesQuery = query.isEmpty ||
                v.name.toLowerCase().contains(query) ||
                v.description.toLowerCase().contains(query) ||
                v.location.toLowerCase().contains(query);
            final matchesLocation =
                _selectedLocation == null || v.location == _selectedLocation;
            final min = priceOpt['min'] as double;
            final max = priceOpt['max'] as double?;
            final matchesPrice =
                v.price >= min && (max == null || v.price <= max);
            return matchesQuery && matchesLocation && matchesPrice;
          }).toList();

          return Column(
            children: [
              // Filters section (search, location, price)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'ابحث بالاسم أو الوصف أو الموقع',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedLocation,
                          hint: const Text('المدينة'),
                          items: [null, ..._locations].map((loc) {
                            return DropdownMenuItem<String>(
                              value: loc,
                              child: Text(loc ?? 'الكل'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedLocation = val),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'إعادة ضبط الفلاتر',
                          onPressed: _resetFilters,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _priceOptions.length,
                        itemBuilder: (ctx, i) {
                          final opt = _priceOptions[i];
                          final selected = i == _selectedPriceIndex;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(opt['label'] as String),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedPriceIndex = i),
                              selectedColor: Theme.of(context).primaryColor,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Listings
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final v = filtered[i];
                    // First image from v.images if you updated the model, else fallback to imageUrl
                    String displayUrl = v.imageUrl;
                    if (v.images != null && v.images.isNotEmpty) {
                      displayUrl = v.images.first;
                    }

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VillaDetailScreen(villa: v),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: displayUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: displayUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                    : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.home,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          v.location,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${v.price.toStringAsFixed(0)} JD / ليلة',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        if (v.hasPool)
                                          const Tooltip(
                                            message: 'مسبح',
                                            child: Icon(Icons.pool, size: 18),
                                          ),
                                        if (v.hasWifi)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Tooltip(
                                              message: 'واي فاي',
                                              child: Icon(Icons.wifi, size: 18),
                                            ),
                                          ),
                                        if (v.hasBarbecue)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Tooltip(
                                              message: 'شواء',
                                              child: Icon(Icons.outdoor_grill, size: 18),
                                            ),
                                          ),
                                        const Spacer(),
                                        Text('سعة: ${v.capacity}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
