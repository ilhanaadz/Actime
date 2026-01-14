import 'package:flutter/material.dart';

class TableHeaderWidget extends StatelessWidget {
  final List<TableHeaderColumn> columns;

  const TableHeaderWidget({
    super.key,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: columns.map((column) {
          return Expanded(
            flex: column.flex,
            child: Text(
              column.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TableHeaderColumn {
  final String title;
  final int flex;

  const TableHeaderColumn({
    required this.title,
    this.flex = 1,
  });
}