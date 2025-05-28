import 'package:json_annotation/json_annotation.dart';

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

class GroupRoleConverter implements JsonConverter<GroupRole, String> {
  const GroupRoleConverter();

  @override
  GroupRole fromJson(String json) {
    return GroupRole.values.firstWhere(
      (e) => e.label == json,
      orElse: () => GroupRole.user,
    );
  }

  @override
  String toJson(GroupRole category) => category.label;
}

enum GroupRole {
  admin('admin'),
  user('user');

  final String label;
  const GroupRole(this.label);
}

class FriendStatusConverter implements JsonConverter<FriendStatus, String> {
  const FriendStatusConverter();

  @override
  FriendStatus fromJson(String json) {
    return FriendStatus.values.firstWhere(
      (e) => e.label == json,
      orElse: () => FriendStatus.requested,
    );
  }

  @override
  String toJson(FriendStatus category) => category.label;
}

enum FriendStatus {
  requested('requested'),
  accepted('accepted');

  final String label;
  const FriendStatus(this.label);
}
