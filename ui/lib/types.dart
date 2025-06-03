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

class Expense {
  final String name;
  final String price;
  final String expenseId;

  Expense({required this.name, required this.price, required this.expenseId});
}

class Friend {
  final String userId;
  final String firstName;
  final String lastName;
  final String nickname;
  bool isSelected = false;

  Friend({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.nickname,

    this.isSelected = false,
  });

  String get name => '$firstName $lastName';
}

class Group {
  final String groupId;
  final String name;
  final String description;

  Group({required this.groupId, required this.name, required this.description});
}

enum FriendRequestViewStatus { friend, sent, incoming }

class FriendRequest {
  final Friend friend;
  final FriendRequestViewStatus status;

  FriendRequest({required this.friend, required this.status});
}
