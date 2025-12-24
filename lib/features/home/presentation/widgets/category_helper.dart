import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'jewelery':
        return Icons.diamond;
      case "men's clothing":
        return Icons.man;
      case "women's clothing":
        return Icons.woman;
      case 'all':
        return Icons.apps;
      default:
        return Icons.category;
    }
  }

  static String formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case "men's clothing":
        return "Men";
      case "women's clothing":
        return "Women";
      case 'electronics':
        return "Tech";
      case 'jewelery':
        return 'Jewelry';
      default:
        return category;
    }
  }
}
