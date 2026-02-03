import 'package:flutter/material.dart';

class EventFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const EventFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterTab('All'),
          const SizedBox(width: 8),
          _buildFilterTab('Pending'),
          const SizedBox(width: 8),
          _buildFilterTab('Upcoming'),
          const SizedBox(width: 8),
          _buildFilterTab('In Progress'),
          const SizedBox(width: 8),
          _buildFilterTab('Completed'),
          const SizedBox(width: 8),
          _buildFilterTab('Cancelled'),
          const SizedBox(width: 8),
          _buildFilterTab('Postponed'),
          const SizedBox(width: 8),
          _buildFilterTab('Rescheduled'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = selectedFilter == label;
    return InkWell(
      onTap: () => onFilterChanged(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D7C8C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D7C8C) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}