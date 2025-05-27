import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

class ExpenseCategoryConverter
    implements JsonConverter<ExpenseCategory, String> {
  const ExpenseCategoryConverter();

  @override
  ExpenseCategory fromJson(String json) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.label == json,
      orElse: () => ExpenseCategory.other,
    );
  }

  @override
  String toJson(ExpenseCategory category) => category.label;
}

enum ExpenseCategory {
  takeaway('takeaway'),
  education('education'),
  entertainment('entertainment'),
  donations('donations'),
  groceries('groceries'),
  health('health'),
  home('home'),
  bills('bills'),
  insurance('insurance'),
  subscriptions('subscriptions'),
  transfers('transfers'),
  travel('travel'),
  utilities('utilities'),
  transport('transport'),
  other('other'),
  auto('auto');

  final String label;
  const ExpenseCategory(this.label);
}

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

  ExpenseItemCreate({
    required this.name,
    required this.quantity,
    required this.price,
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

  ExpenseItemRead({
    required this.expenseItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory ExpenseItemRead.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemReadFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemReadToJson(this);
}
