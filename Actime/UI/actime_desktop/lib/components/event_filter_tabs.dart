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
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterTab('All'),
          _buildFilterTab('Pending'),
          _buildFilterTab('Upcoming'),
          _buildFilterTab('In Progress'),
          _buildFilterTab('Completed'),
          _buildFilterTab('Cancelled'),
          _buildFilterTab('Postponed'),
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