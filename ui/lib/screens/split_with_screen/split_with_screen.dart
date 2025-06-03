// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/expense.dart' show ExpenseItemCreate;
import 'package:flutter_frontend/models/group.dart' show GroupRead;
import 'package:flutter_frontend/models/user.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
// Elements
import '../split_with_screen/elements/split_with_screen_main_body.dart';

class SplitWithScreen extends StatefulWidget {
  final List<ExpenseItemCreate> existingItems;
  final List<GroupRead> groups;
  final List<UserRead> users;
  final bool isReadOnly;

  const SplitWithScreen({
    super.key,
    required this.isReadOnly,
    required this.groups,
    required this.users,
    this.existingItems = const [],
  });

  @override
  State<SplitWithScreen> createState() => _SplitWithScreenState();
}

class _SplitWithScreenState extends State<SplitWithScreen> {
  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: 'Split With', showBackButton: true),

      body: SplitWithScreenMainBody(
        transactionId: "",
        isReadOnly: widget.isReadOnly,
      ),
    );
  }
}
