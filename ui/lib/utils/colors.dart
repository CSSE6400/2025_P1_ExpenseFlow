import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/enums.dart' show ExpenseStatus;

Color statusBackgroundColor(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.paid:
      return Colors.green.withValues(alpha: .2);
    case ExpenseStatus.accepted:
      return Colors.yellow.withValues(alpha: .2);
    case ExpenseStatus.requested:
      return Colors.grey.withValues(alpha: .2);
  }
}

Color statusIconAndTextColor(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.paid:
      return Colors.green;
    case ExpenseStatus.accepted:
      return Colors.yellow;
    case ExpenseStatus.requested:
      return Colors.grey;
  }
}
