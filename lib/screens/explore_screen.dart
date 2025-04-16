import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chip.dart';

class VillaListingsScreen extends StatefulWidget {
  const VillaListingsScreen({super.key});

  @override
  State<VillaListingsScreen> createState() => _VillaListingsScreenState();
}

class _VillaListingsScreenState extends State<VillaListingsScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final villaProvider = Provider.of<VillaProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Search & filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    onSearch: (query) {
                      villaProvider.setSearchQuery(query);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _showFilters
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: _showFilters ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "الفلترة حسب",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => villaProvider.resetFilters(),
                        child: const Text("إعادة ضبط"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChipWidget(
                        label: 'مسبح',
                        isSelected: villaProvider.filters['مسبح'] ?? false,
                        onSelected: (_) => villaProvider.toggleFilter('مسبح'),
                      ),
                      FilterChipWidget(
                        label: 'واي فاي',
                        isSelected: villaProvider.filters['واي فاي'] ?? false,
                        onSelected: (_) => villaProvider.toggleFilter('واي فاي'),
                      ),
                      FilterChipWidget(
                        label: 'شواء',
                        isSelected: villaProvider.filters['شواء'] ?? false,
                        onSelected: (_) => villaProvider.toggleFilter('شواء'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Horizontal categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _buildCategorySection(context, "الأعلى تقييماً", villaProvider.getTopRatedVillas()),
                _buildCategorySection(context, "الأكثر طلباً", villaProvider.getMostPopularVillas()),
                _buildCategorySection(context, "قريب منك", villaProvider.getNearbyVillas("عمان")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Provider.of<VillaProvider>(context, listen: false)
                      .setSelectedCategory(title);
                },
                child: const Text("عرض الكل"),
              ),
            ],
          ),
        ),

        // Horizontal list
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final villa = items[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        villa['image_url'] ?? '',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),

                    // Info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            villa['name'] ?? 'مزرعة بدون اسم',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            villa['location'] ?? 'غير معروف',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${villa['price'].toString().replaceAll(RegExp(r'[^\d.]'), '')} دينار أردني / اليوم',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
