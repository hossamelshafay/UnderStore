import 'package:flutter/material.dart';
import '../widgets/category_item.dart';
import '../widgets/category_helper.dart';

class CategoriesListWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryTap;

  const CategoriesListWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          CategoryItem(
            category: 'All',
            icon: CategoryHelper.getCategoryIcon('all'),
            isSelected: selectedCategory == 'All',
            onTap: () => onCategoryTap('All'),
          ),
          ...categories.map(
            (category) => CategoryItem(
              category: CategoryHelper.formatCategoryName(category),
              icon: CategoryHelper.getCategoryIcon(category),
              isSelected: selectedCategory == category,
              onTap: () => onCategoryTap(category),
            ),
          ),
        ],
      ),
    );
  }
}
