// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SplitStatusInfo _$SplitStatusInfoFromJson(Map<String, dynamic> json) =>
    SplitStatusInfo(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      status: const ExpenseStatusConverter().fromJson(json['status'] as String),
    );

Map<String, dynamic> _$SplitStatusInfoToJson(SplitStatusInfo instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'status': const ExpenseStatusConverter().toJson(instance.status),
    };

ExpenseRead _$ExpenseReadFromJson(Map<String, dynamic> json) => ExpenseRead(
  expenseId: json['expense_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: const ExpenseCategoryConverter().fromJson(
    json['category'] as String,
  ),
  expenseDate: DateTime.parse(json['expense_date'] as String),
  uploader: UserRead.fromJson(json['uploader'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => ExpenseItemRead.fromJson(e as Map<String, dynamic>))
          .toList(),
  expenseTotal: (json['expense_total'] as num).toDouble(),
  status: const ExpenseStatusConverter().fromJson(json['status'] as String),
);

Map<String, dynamic> _$ExpenseReadToJson(ExpenseRead instance) =>
    <String, dynamic>{
      'expense_id': instance.expenseId,
      'name': instance.name,
      'description': instance.description,
      'category': const ExpenseCategoryConverter().toJson(instance.category),
      'expense_date': instance.expenseDate.toIso8601String(),
      'uploader': instance.uploader,
      'items': instance.items,
      'expense_total': instance.expenseTotal,
      'status': const ExpenseStatusConverter().toJson(instance.status),
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
      splits:
          (json['splits'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ExpenseItemSplitCreate.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$ExpenseCreateToJson(ExpenseCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'expense_date': instance.expenseDate.toIso8601String(),
      'items': instance.items,
      'splits': instance.splits,
      'category': const ExpenseCategoryConverter().toJson(instance.category),
    };

ExpenseItemRead _$ExpenseItemReadFromJson(Map<String, dynamic> json) =>
    ExpenseItemRead(
      expenseItemId: json['expense_item_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      splits:
          (json['splits'] as List<dynamic>)
              .map(
                (e) =>
                    ExpenseItemSplitCreate.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$ExpenseItemReadToJson(ExpenseItemRead instance) =>
    <String, dynamic>{
      'expense_item_id': instance.expenseItemId,
      'name': instance.name,
      'quantity': instance.quantity,
      'price': instance.price,
      'splits': instance.splits,
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

ExpenseItemSplitCreate _$ExpenseItemSplitCreateFromJson(
  Map<String, dynamic> json,
) => ExpenseItemSplitCreate(
  userId: json['user_id'] as String,
  proportion: (json['proportion'] as num).toDouble(),
);

Map<String, dynamic> _$ExpenseItemSplitCreateToJson(
  ExpenseItemSplitCreate instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'proportion': instance.proportion,
};

ExpenseItemSplitRead _$ExpenseItemSplitReadFromJson(
  Map<String, dynamic> json,
) => ExpenseItemSplitRead(
  userId: json['user_id'] as String,
  proportion: (json['proportion'] as num).toDouble(),
  userFullname: json['user_fullname'] as String,
  status: const ExpenseStatusConverter().fromJson(json['status'] as String),
);

Map<String, dynamic> _$ExpenseItemSplitReadToJson(
  ExpenseItemSplitRead instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'proportion': instance.proportion,
  'user_fullname': instance.userFullname,
  'status': const ExpenseStatusConverter().toJson(instance.status),
};

ExpenseOverviewCategory _$ExpenseOverviewCategoryFromJson(
  Map<String, dynamic> json,
) => ExpenseOverviewCategory(
  total: (json['total'] as num).toDouble(),
  category: const ExpenseCategoryConverter().fromJson(
    json['category'] as String,
  ),
);

Map<String, dynamic> _$ExpenseOverviewCategoryToJson(
  ExpenseOverviewCategory instance,
) => <String, dynamic>{
  'category': const ExpenseCategoryConverter().toJson(instance.category),
  'total': instance.total,
};

ExpenseOverview _$ExpenseOverviewFromJson(Map<String, dynamic> json) =>
    ExpenseOverview(
      total: (json['total'] as num).toDouble(),
      categories:
          (json['categories'] as List<dynamic>)
              .map(
                (e) =>
                    ExpenseOverviewCategory.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$ExpenseOverviewToJson(ExpenseOverview instance) =>
    <String, dynamic>{
      'total': instance.total,
      'categories': instance.categories,
    };
