import 'package:flutter_frontend/models/enums.dart'
    show ExpenseCategory, ExpenseCategoryConverter;
import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseRead {
  final String expenseId;
  final String name;
  final String description;
  final DateTime expenseDate;

  @ExpenseCategoryConverter()
  final ExpenseCategory category;

  ExpenseRead({
    required this.expenseId,
    required this.name,
    required this.expenseDate,
    required this.description,
    required this.category,
  });

  factory ExpenseRead.fromJson(Map<String, dynamic> json) =>
      _$ExpenseReadFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseReadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseCreate {
  final String name;
  final String description;
  final DateTime expenseDate;

  final List<ExpenseItemCreate> items;

  @ExpenseCategoryConverter()
  final ExpenseCategory category;

  ExpenseCreate({
    required this.name,
    required this.description,
    required this.expenseDate,
    required this.category,
    required this.items,
  });

  factory ExpenseCreate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseItemCreate {
  final String name;
  final int quantity;
  final double price;
  final List<ExpenseItemCreate>? items;

  ExpenseItemCreate({
    required this.name,
    required this.quantity,
    required this.price,
    this.items,
  });

  factory ExpenseItemCreate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseItemRead {
  final String expenseItemId;
  final String name;
  final int quantity;
  final double price;
  final List<ExpenseItemCreate> items;

  ExpenseItemRead({
    required this.expenseItemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.items,
  });

  factory ExpenseItemRead.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemReadFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemReadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseItemSplitCreate {
  final String userId;
  final double proportion;

  ExpenseItemSplitCreate({required this.userId, required this.proportion});

  factory ExpenseItemSplitCreate.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemSplitCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemSplitCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseItemSplitRead {
  final String userId;
  final double proportion;
  final String userFullname;

  ExpenseItemSplitRead({
    required this.userId,
    required this.proportion,
    required this.userFullname,
  });

  factory ExpenseItemSplitRead.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemSplitReadFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemSplitReadToJson(this);
}
