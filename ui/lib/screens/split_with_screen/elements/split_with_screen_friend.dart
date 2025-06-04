import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/custom_divider.dart';
import 'package:flutter_frontend/common/icon_maker.dart';
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';

class FriendSplit {
  String name;
  String userId;
  String percentage;
  bool checked;
  final TextEditingController controller;

  FriendSplit({
    required this.name,
    required this.userId,
    required this.percentage,
    required this.checked,
  }) : controller = TextEditingController(text: percentage);
}

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
  List<FriendSplit> friendSplits = [];
  final Logger _logger = Logger("SplitWithFriends");
  String currentUserId = '';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged.call(isTotalPercentageValid());
    });

    final Set<String> uniqueUserIds = {};
    for (var split in widget.splits) {
      uniqueUserIds.add(split.userId);
    }

    friendSplits =
        widget.friends.map((friend) {
          return FriendSplit(
            name: friend.nickname,
            userId: friend.userId,
            percentage:
                getUserProption(friend.userId, widget.splits) != null
                    ? (getUserProption(friend.userId, widget.splits)! * 100)
                        .toStringAsFixed(0)
                    : '',
            checked: uniqueUserIds.contains(friend.userId),
          );
        }).toList();

    // add the current user as a special case
    friendSplits.add(
      FriendSplit(
        name: "You",
        userId: widget.currentUser.userId,
        percentage:
            getUserProption(widget.currentUser.userId, widget.splits) != null
                ? (getUserProption(widget.currentUser.userId, widget.splits)! *
                        100)
                    .toStringAsFixed(0)
                : (uniqueUserIds.isEmpty ? '100' : ''),
        checked:
            uniqueUserIds.contains(widget.currentUser.userId) ||
            uniqueUserIds.isEmpty,
      ),
    );
  }

  void _toggleFriendSelection(FriendSplit friend) {
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
    final selectedFriends = friendSplits.where(
      (f) => f.checked || f.name == 'You',
    );
    final total = selectedFriends.fold<double>(
      0,
      (sum, f) => sum + (double.tryParse(f.percentage) ?? 0),
    );
    return total == 100;
  }

  void _updateSplits() {
    _logger.info('Updating splits with current selections');
    _logger.info("Current splits: ${widget.splits}");
    final splits = <ExpenseItemSplitCreate>[];

    for (var friend in friendSplits) {
      // Include if checked OR if it's the current user ("You")
      if (friend.checked || friend.userId == widget.currentUser.userId) {
        final percentage = double.tryParse(friend.percentage) ?? 0.0;
        if (percentage < 0) {}
        splits.add(
          ExpenseItemSplitCreate(
            userId: friend.userId,
            proportion: percentage / 100.0,
          ),
        );
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
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDivider(),

          ...friendSplits.map((friend) {
            return GestureDetector(
              onTap: () => _toggleFriendSelection(friend),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      friend.name,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleHeight(16),
                        color:
                            friend.checked
                                ? textColor
                                : ColorPalette.secondaryText,
                      ),
                    ),
                    Row(
                      children: [
                        if (friend.checked || friend.name == 'You')
                          Padding(
                            padding: EdgeInsets.only(
                              right: proportionalSizes.scaleWidth(6),
                            ),
                            child: IconMaker(
                              assetPath: 'assets/icons/check_nofilled.png',
                            ),
                          ),
                        Container(
                          width: proportionalSizes.scaleWidth(70),
                          padding: EdgeInsets.symmetric(
                            horizontal: proportionalSizes.scaleWidth(8),
                            vertical: proportionalSizes.scaleHeight(4),
                          ),
                          decoration: BoxDecoration(
                            color:
                                (friend.checked || friend.name == 'You')
                                    ? ColorPalette.secondaryText.withAlpha(100)
                                    : textColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(
                              proportionalSizes.scaleWidth(6),
                            ),
                          ),
                          child: TextField(
                            controller: friend.controller,
                            enabled:
                                !widget.isReadOnly &&
                                (friend.checked || friend.name == 'You'),
                            keyboardType: TextInputType.number,
                            onChanged:
                                widget.isReadOnly
                                    ? null
                                    : (value) {
                                      setState(() {
                                        friend.percentage = value;
                                        widget.onValidityChanged.call(
                                          isTotalPercentageValid(),
                                        );
                                        _updateSplits();
                                      });
                                    },
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: proportionalSizes.scaleHeight(14),
                              color:
                                  (friend.checked || friend.name == 'You')
                                      ? textColor
                                      : ColorPalette.secondaryText,
                            ),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              suffixText: '%',
                              suffixStyle: TextStyle(color: Color(0xFF0F2F63)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
