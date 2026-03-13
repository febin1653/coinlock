import 'package:flutter/material.dart';
import '../models/transaction.dart';

class FilterControlsWidget extends StatelessWidget {
  final dynamic selectedType;
  final dynamic selectedCategory;
  final String selectedPerson;
  final Function(dynamic) onTypeChange;
  final Function(dynamic) onCategoryChange;
  final Function(String) onPersonChange;
  final List<String> people;

  const FilterControlsWidget({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedPerson,
    required this.onTypeChange,
    required this.onCategoryChange,
    required this.onPersonChange,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filters",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<dynamic>(
                  label: "TYPE",
                  value: selectedType,
                  items: ['all', ...TransactionType.values],
                  onChanged: onTypeChange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<dynamic>(
                  label: "CATEGORY",
                  value: selectedCategory,
                  items: ['all', ...Category.values],
                  onChanged: onCategoryChange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<String>(
                  label: "PERSON",
                  value: selectedPerson.isEmpty ? 'all' : selectedPerson,
                  items: ['all', ...people],
                  onChanged: (val) => onPersonChange(val == 'all' ? '' : val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: items.map((T val) {
                String text = val.toString().split('.').last;
                return DropdownMenuItem<T>(
                  value: val,
                  child: Text(text.toUpperCase()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}