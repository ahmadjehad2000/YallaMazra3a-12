import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/villa_provider.dart';
import '../widgets/villa_card.dart';
import '../widgets/search_bar.dart';

class VillaListingsScreen extends StatefulWidget {
  const VillaListingsScreen({Key? key}) : super(key: key);

  @override
  _VillaListingsScreenState createState() => _VillaListingsScreenState();
}

class _VillaListingsScreenState extends State<VillaListingsScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CustomSearchBar(
              onSearch: (query) {
                Provider.of<VillaProvider>(context, listen: false)
                    .setSearchQuery(query);
              },
            ),
          ),
          
          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                filterChip(context, 'الكل'),
                filterChip(context, 'الأعلى تقييماً'),
                filterChip(context, 'الأكثر طلباً'),
                filterChip(context, 'قريب منك'),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Villa listings
          Expanded(
            child: Consumer<VillaProvider>(
              builder: (context, villaProvider, child) {
                final villas = villaProvider.filteredVillas;
                
                if (villas.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "لا توجد مزارع تطابق البحث",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: villas.length,
                  itemBuilder: (context, index) {
                    final villa = villas[index];
                    return VillaCard(villa: villa);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(BuildContext context, String label) {
    final villaProvider = Provider.of<VillaProvider>(context);
    final isSelected = villaProvider.selectedCategory == label;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            villaProvider.setSelectedCategory(label);
          }
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
