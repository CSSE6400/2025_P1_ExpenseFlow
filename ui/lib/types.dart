import 'dart:math' show Random;

import 'package:flutter/material.dart';

class CategoryData {
  final String name;
  final double amount;
  Color? color;

  CategoryData({required this.name, required this.amount, this.color});
}

List<CategoryData> assignRandomColors(
  List<CategoryData> categories,
  List<Color> colors,
) {
  final random = Random();
  return categories.map((category) {
    return CategoryData(
      name: category.name,
      amount: category.amount,
      color: colors[random.nextInt(colors.length)],
    );
  }).toList();
}
