// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart'
    show ButtonSizeType, ButtonState, CustomButton;
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/group.dart' show GroupReadWithMembers;
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/screens/split_with_screen/elements/split_with_screen_friend.dart'
    show SplitWithScreenFriend;
import 'package:flutter_frontend/screens/split_with_screen/elements/split_with_screen_group.dart'
    show SplitWithScreenGroup;
import 'package:flutter_frontend/screens/split_with_screen/elements/split_with_screen_segment_control.dart'
    show SplitWithScreenSegmentControl, SplitWithSegment;
import 'package:logging/logging.dart';
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
// Elements

class UserSplit {
  String name;
  String userId;
  String percentage;
  bool checked;
  final TextEditingController controller;

  UserSplit({
    required this.name,
    required this.userId,
    required this.percentage,
    required this.checked,
  }) : controller = TextEditingController(text: percentage);
}

class SplitWithScreen extends StatefulWidget {
  final List<ExpenseItemSplitCreate> splits;
  final List<GroupReadWithMembers> groups;
  final List<UserRead> friends;
  final UserRead currentUser;

  final bool isReadOnly;

  final SplitWithSegment?
  strictSegment; // Used when modifying expenses (can't switch segments)

  const SplitWithScreen({
    super.key,
    required this.isReadOnly,
    required this.groups,
    required this.friends,
    required this.splits,
    required this.currentUser,
    this.strictSegment,
  });

  @override
  State<SplitWithScreen> createState() => _SplitWithScreenState();
}

class _SplitWithScreenState extends State<SplitWithScreen> {
  late SplitWithSegment _segment;
  List<ExpenseItemSplitCreate> _splits = [];
  final Logger _logger = Logger("SplitWithScreen");

  bool isFriendValid = false;
  bool isGroupValid = false;

  void updateSegment(SplitWithSegment newSegment) {
    setState(() {
      _segment = newSegment;
    });
  }

  @override
  void initState() {
    super.initState();
    _segment = widget.strictSegment ?? SplitWithSegment.friend;
    _splits = widget.splits;
  }

  // callback to update item splits
  void _updateItemSplits(List<ExpenseItemSplitCreate> newSplits) {
    setState(() {
      _splits = newSplits;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final isContinueEnabled =
        _segment == SplitWithSegment.friend ? isFriendValid : isGroupValid;

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Split With', showBackButton: true),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(0),
            ),
            child: Column(
              children: [
                if (widget.strictSegment == null) // can't change segment
                  SplitWithScreenSegmentControl(
                    selectedSegment: _segment,
                    onSegmentChanged: updateSegment,
                  ),
                SizedBox(height: proportionalSizes.scaleHeight(10)),

                // Friend or Group view
                _segment == SplitWithSegment.friend
                    ? SplitWithScreenFriend(
                      friends: widget.friends,
                      splits: _splits,
                      currentUser: widget.currentUser,
                      onValidityChanged: (valid) {
                        setState(() {
                          isFriendValid = valid;
                        });
                      },
                      onSplitsUpdated: _updateItemSplits,
                      isReadOnly: widget.isReadOnly,
                    )
                    : SplitWithScreenGroup(
                      groups: widget.groups,
                      splits: _splits,
                      currentUser: widget.currentUser,
                      onValidityChanged: (valid) {
                        setState(() {
                          isGroupValid = valid;
                        });
                      },
                      onSplitsUpdated: _updateItemSplits,
                      isReadOnly: widget.isReadOnly,
                    ),
                if (!widget.isReadOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomButton(
                      label: 'Confirm Splits',
                      onPressed: _saveAndReturn,
                      state:
                          isContinueEnabled
                              ? ButtonState.enabled
                              : ButtonState.disabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // return items to calling screen
  void _saveAndReturn() {
    _logger.info('Saving splits: ${_splits.map((e) => e.toJson())}');
    Navigator.pop(context, _splits);
  }
}
