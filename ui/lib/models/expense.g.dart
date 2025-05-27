// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseRead _$ExpenseReadFromJson(Map<String, dynamic> json) => ExpenseRead(
  expenseId: json['expense_id'] as String,
  name: json['name'] as String,
  expenseDate: DateTime.parse(json['expense_date'] as String),
  description: json['description'] as String,
  category: const ExpenseCategoryConverter().fromJson(
    json['category'] as String,
  ),
);

Map<String, dynamic> _$ExpenseReadToJson(ExpenseRead instance) =>
    <String, dynamic>{
      'expense_id': instance.expenseId,
      'name': instance.name,
      'description': instance.description,
      'expense_date': instance.expenseDate.toIso8601String(),
      'category': const ExpenseCategoryConverter().toJson(instance.category),
    };

ExpenseCreate _$ExpenseCreateFromJson(Map<String, dynamic> json) =>
    ExpenseCreate(
      name: json['name'] as String,
      description: json['description'] as String,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      category: const ExpenseCategoryConverter().fromJson(
        json['category'] as String,
      ),
      items:
          (json['items'] as List<dynamic>)
              .map((e) => ExpenseItemCreate.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ExpenseCreateToJson(ExpenseCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'expense_date': instance.expenseDate.toIso8601String(),
      'items': instance.items,
      'category': const ExpenseCategoryConverter().toJson(instance.category),
    };

ExpenseItemCreate _$ExpenseItemCreateFromJson(Map<String, dynamic> json) =>
    ExpenseItemCreate(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseItemCreateToJson(ExpenseItemCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };

ExpenseItemRead _$ExpenseItemReadFromJson(Map<String, dynamic> json) =>
    ExpenseItemRead(
      expenseItemId: json['expense_item_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$ExpenseItemReadToJson(ExpenseItemRead instance) =>
    <String, dynamic>{
      'expense_item_id': instance.expenseItemId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
    };
