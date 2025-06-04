import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_divider.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/screens/split_with_screen/split_with_screen.dart'
    show UserSplit;
import 'package:flutter_frontend/widgets/user_split_view.dart'
    show UserSplitWidget;
import 'package:logging/logging.dart';

class SplitWithScreenFriend extends StatefulWidget {
  final List<UserRead> friends;
  final List<ExpenseItemSplitCreate> splits;
  final UserRead currentUser;

  final void Function(bool isValid) onValidityChanged;
  final Function(List<ExpenseItemSplitCreate> splits) onSplitsUpdated;
  final bool isReadOnly;

  const SplitWithScreenFriend({
    super.key,
    required this.friends,
    required this.splits,
    required this.currentUser,
    required this.onValidityChanged,
    required this.onSplitsUpdated,
    required this.isReadOnly,
  });

  @override
  State<SplitWithScreenFriend> createState() => SplitWithScreenFriendState();
}

class SplitWithScreenFriendState extends State<SplitWithScreenFriend> {
  List<UserSplit> friendSplits = [];
  final Logger _logger = Logger("SplitWithFriends");

  double? getUserProption(String userId, List<ExpenseItemSplitCreate> splits) {
    for (var split in splits) {
      if (split.userId == userId) {
        return split.proportion;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    final Set<String> uniqueUserIds = {};
    for (var split in widget.splits) {
      uniqueUserIds.add(split.userId);
    }

    friendSplits =
        widget.friends.map((friend) {
          final perc = getUserProption(friend.userId, widget.splits);
          final percText = perc != null ? (perc * 100).toStringAsFixed(0) : '';
          final userSplit = UserSplit(
            name: friend.nickname,
            userId: friend.userId,
            percentage: percText,
            checked: uniqueUserIds.contains(friend.userId),
          );
          userSplit.controller.text = percText;
          return userSplit;
        }).toList();

    final currentUserPerc = getUserProption(
      widget.currentUser.userId,
      widget.splits,
    );
    final currentUserPercText =
        currentUserPerc != null
            ? (currentUserPerc * 100).toStringAsFixed(0)
            : (uniqueUserIds.isEmpty ? '100' : '');
    final currentUserSplit = UserSplit(
      name: "You",
      userId: widget.currentUser.userId,
      percentage: currentUserPercText,
      checked:
          uniqueUserIds.contains(widget.currentUser.userId) ||
          uniqueUserIds.isEmpty,
    );
    currentUserSplit.controller.text = currentUserPercText;
    friendSplits.add(currentUserSplit);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged.call(isTotalPercentageValid());
    });
  }

  @override
  void dispose() {
    for (var friend in friendSplits) {
      friend.controller.dispose();
    }
    super.dispose();
  }

  void _toggleFriendSelection(UserSplit friend) {
    _logger.info(
      'Toggling selection for ${friend.name} (checked: ${friend.checked})',
    );
    setState(() {
      friend.checked = !friend.checked;

      if (friend.checked && friend.percentage.isEmpty) {
        friend.percentage = '0';
        friend.controller.text = '0';
      }

      if (!friend.checked) {
        friend.percentage = '';
        friend.controller.text = '';
      }

      widget.onValidityChanged.call(isTotalPercentageValid());
      _updateSplits();
    });
  }

  bool isTotalPercentageValid() {
    final selectedFriends = friendSplits.where((f) => f.checked);
    final total = selectedFriends.fold<double>(
      0,
      (sum, f) => sum + (double.tryParse(f.percentage) ?? 0),
    );
    return total == 100;
  }

  void _updateSplits() {
    _logger.info('Updating splits with current selections');
    final splits = <ExpenseItemSplitCreate>[];

    for (var friend in friendSplits) {
      if (friend.checked || friend.name == 'You') {
        final percentage = double.tryParse(friend.percentage) ?? 0.0;
        if (percentage > 0) {
          splits.add(
            ExpenseItemSplitCreate(
              userId: friend.userId,
              proportion: percentage / 100.0,
            ),
          );
        }
      }
    }

    _logger.info("Updated splits: $splits");
    widget.onSplitsUpdated(splits);
  }

  void saveAndExit(BuildContext context) {
    _logger.info('Saving splits and exiting');
    _updateSplits();
    Navigator.pop(context, widget.splits);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDivider(),

          ...friendSplits.map((friend) {
            return UserSplitWidget(
              user: friend,
              isReadOnly: widget.isReadOnly,
              onTap: () => _toggleFriendSelection(friend),
              onChanged: (value) {
                if (widget.isReadOnly) return;
                setState(() {
                  friend.percentage = value;
                  widget.onValidityChanged.call(isTotalPercentageValid());
                  _updateSplits();
                });
              },
            );
          }),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
