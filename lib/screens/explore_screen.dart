import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/villa_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_chip.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar and filter button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomSearchBar(
                    onSearch: (query) {
                      Provider.of<VillaProvider>(context, listen: false)
                          .setSearchQuery(query);
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
          
          // Filters
          if (_showFilters)
            Consumer<VillaProvider>(
              builder: (context, villaProvider, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              villaProvider.resetFilters();
                            },
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
                            onSelected: (selected) {
                              villaProvider.toggleFilter('مسبح');
                            },
                          ),
                          FilterChipWidget(
                            label: 'واي فاي',
                            isSelected: villaProvider.filters['واي فاي'] ?? false,
                            onSelected: (selected) {
                              villaProvider.toggleFilter('واي فاي');
                            },
                          ),
                          FilterChipWidget(
                            label: 'شواء',
                            isSelected: villaProvider.filters['شواء'] ?? false,
                            onSelected: (selected) {
                              villaProvider.toggleFilter('شواء');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          
          // Categories and villa listings
          Expanded(
            child: Consumer<VillaProvider>(
              builder: (context, villaProvider, _) {
                return ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    _buildCategorySection(
                      context,
                      "الأعلى تقييماً",
                      villaProvider.getTopRatedVillas(),
                    ),
                    _buildCategorySection(
                      context,
                      "الأكثر طلباً",
                      villaProvider.getMostPopularVillas(),
                    ),
                    _buildCategorySection(
                      context,
                      "قريب منك",
                      villaProvider.getNearbyVillas("الرياض"),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Set category filter and navigate to listings
                  Provider.of<VillaProvider>(context, listen: false)
                      .setSelectedCategory(title);
                },
                child: const Text("عرض الكل"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280,
                child: VillaCard(
                  villa: items[index],
                  isHorizontal: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
