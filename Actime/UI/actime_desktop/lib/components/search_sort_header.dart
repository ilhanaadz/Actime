import 'package:flutter/material.dart';

class SearchSortHeader extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  final List<PopupMenuItem<String>> sortItems;
  final Function(String)? onSortSelected;
  final Widget? additionalActions;

  const SearchSortHeader({
    super.key,
    required this.title,
    required this.searchController,
    required this.sortItems,
    this.onSortSelected,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          
          // Search TextField
          SizedBox(
            width: 300,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D7C8C)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Sort Dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0xFF0D7C8C)),
            tooltip: 'Sort',
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: onSortSelected,
            itemBuilder: (context) => sortItems,
          ),
          
          if (additionalActions != null) ...[
            const SizedBox(width: 8),
            additionalActions!,
          ],
        ],
      ),
    );
  }
}