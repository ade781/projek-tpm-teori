import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final List<Map<String, dynamic>> searchSuggestions;
  final Function(Map<String, dynamic>) onSuggestionTapped;

  const MapSearchBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.searchSuggestions,
    required this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(30),
            shadowColor: Colors.black.withOpacity(0.4),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari masjid, gereja, pura...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 12.0),
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            searchController.clear();
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
        ),

        // Suggestions List with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          height: searchSuggestions.isNotEmpty ? 200.0 : 0.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (searchSuggestions.isNotEmpty)
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchSuggestions.length,
              itemBuilder: (context, index) {
                final feature = searchSuggestions[index];
                final name = feature['properties']['name'] ?? 'Tanpa Nama';
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                  title: Text(name),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    onSuggestionTapped(feature);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
