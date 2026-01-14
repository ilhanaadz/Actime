import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        IconButton(
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
          color: currentPage > 1 ? Colors.grey[700] : Colors.grey[300],
        ),

        const SizedBox(width: 8),

        // Page Numbers
        ...List.generate(
          totalPages > 5 ? 5 : totalPages,
          (index) {
            int pageNumber;
            
            if (totalPages <= 5) {
              pageNumber = index + 1;
            } else if (currentPage <= 3) {
              pageNumber = index + 1;
            } else if (currentPage >= totalPages - 2) {
              pageNumber = totalPages - 4 + index;
            } else {
              pageNumber = currentPage - 2 + index;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPageButton(pageNumber),
            );
          },
        ),

        if (totalPages > 5 && currentPage < totalPages - 2) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildPageButton(totalPages),
          ),
        ],

        const SizedBox(width: 8),

        // Next Button
        IconButton(
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
          color: currentPage < totalPages ? Colors.grey[700] : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isActive = pageNumber == currentPage;

    return InkWell(
      onTap: () => onPageChanged(pageNumber),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D7C8C) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF0D7C8C) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
