import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// A generic searchable dropdown with "Add new" option
/// T is the type of items in the dropdown
class SearchableDropdown<T> extends StatefulWidget {
  final String labelText;
  final String hintText;
  final T? selectedValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final String Function(T)? itemSubtitle;
  final ValueChanged<T?> onChanged;
  final VoidCallback? onAddNew;
  final String addNewLabel;
  final bool isLoading;
  final bool isOutlined;

  const SearchableDropdown({
    super.key,
    required this.labelText,
    this.hintText = 'Odaberi...',
    this.selectedValue,
    required this.items,
    required this.itemLabel,
    this.itemSubtitle,
    required this.onChanged,
    this.onAddNew,
    this.addNewLabel = 'Dodaj novu',
    this.isLoading = false,
    this.isOutlined = true,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _filterItems(_searchController.text);
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final label = widget.itemLabel(item).toLowerCase();
          final subtitle = widget.itemSubtitle?.call(item).toLowerCase() ?? '';
          return label.contains(query.toLowerCase()) ||
              subtitle.contains(query.toLowerCase());
        }).toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    if (_isOpen) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filteredItems = widget.items;
    if (mounted) {
      setState(() => _isOpen = false);
    }
    _isOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Pretrazi...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: _filterItems,
                    ),
                  ),
                  const Divider(height: 1),
                  // Items list
                  Flexible(
                    child: widget.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              ..._filteredItems.map((item) => ListTile(
                                    dense: true,
                                    title: Text(
                                      widget.itemLabel(item),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    subtitle: widget.itemSubtitle != null
                                        ? Text(
                                            widget.itemSubtitle!(item),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          )
                                        : null,
                                    selected: widget.selectedValue == item,
                                    selectedTileColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    onTap: () {
                                      widget.onChanged(item);
                                      _hideOverlay();
                                    },
                                  )),
                              if (_filteredItems.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Nema rezultata',
                                    style: TextStyle(color: AppColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                  ),
                  // Add new option
                  if (widget.onAddNew != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      title: Text(
                        widget.addNewLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        _hideOverlay();
                        widget.onAddNew!();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isOpen) {
            _hideOverlay();
          } else {
            _showOverlay();
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(color: AppColors.primary),
            suffixIcon: Icon(
              _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
            enabledBorder: widget.isOutlined
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderLight),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
            focusedBorder: widget.isOutlined
                ? OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  )
                : const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.selectedValue != null
                      ? widget.itemLabel(widget.selectedValue as T)
                      : widget.hintText,
                  style: TextStyle(
                    color: widget.selectedValue != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
        ),
      ),
    );
  }
}
