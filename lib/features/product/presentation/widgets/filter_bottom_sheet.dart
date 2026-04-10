import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';

class FilterBottomSheet extends StatefulWidget {
  final String sortBy;
  final String sortOrder;
  final Function(String sortBy, String sortOrder) onSortChanged;

  const FilterBottomSheet({
    super.key,
    required this.sortBy,
    required this.sortOrder,
    required this.onSortChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedSortBy;
  late String _selectedSortOrder;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.sortBy;
    _selectedSortOrder = widget.sortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('filter_sort'),
                style: AppTextStyles.h2,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 32),

          // Sort By
          Text(
            context.tr('sort_by'),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildSortOption('name', context.tr('name')),
          _buildSortOption('price', context.tr('price')),
          _buildSortOption('newest', context.tr('newest')),

          const SizedBox(height: 24),

          // Sort Order
          Text(
            context.tr('sort_order'),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildSortOrderOption('asc', context.tr('ascending')),
          _buildSortOrderOption('desc', context.tr('descending')),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr('apply'),
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedSortBy,
      onChanged: (val) {
        setState(() {
          _selectedSortBy = val!;
        });
      },
      title: Text(label),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSortOrderOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedSortOrder,
      onChanged: (val) {
        setState(() {
          _selectedSortOrder = val!;
        });
      },
      title: Text(label),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
