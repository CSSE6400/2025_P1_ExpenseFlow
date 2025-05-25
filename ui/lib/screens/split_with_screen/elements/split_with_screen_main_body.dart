import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';
import '../../../common/custom_button.dart';
import 'split_with_screen_segment_control.dart';
import 'split_with_screen_friend.dart';
import 'split_with_screen_group.dart';

class SplitWithScreenMainBody extends StatefulWidget {
  final String? transactionId;
  final bool isReadOnly;

  const SplitWithScreenMainBody({
    super.key,
    this.transactionId,
    this.isReadOnly = false,
  });

  @override
  State<SplitWithScreenMainBody> createState() =>
      _SplitWithScreenMainBodyState();
}

class _SplitWithScreenMainBodyState extends State<SplitWithScreenMainBody> {
  String selectedSegment = 'Friend';

  final GlobalKey<SplitWithScreenFriendState> friendKey =
      GlobalKey<SplitWithScreenFriendState>();
  final GlobalKey<SplitWithScreenGroupState> groupKey =
      GlobalKey<SplitWithScreenGroupState>();

  bool isFriendValid = false;
  bool isGroupValid = false;

  @override
  void initState() {
    super.initState();

    if (widget.transactionId != null) {
      // TODO: If transactionId is provided, fetch split-with data from backend.
      // 1. Set `selectedSegment` to either 'Friend' or 'Group'.
      // 2. Populate the corresponding widget (friendKey/groupKey) with the data.
      // Helps pre-fill the screen for editing or read-only display.
    }
  }

  void updateSegment(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

  // TODO: Handle the continue button action for updates through see expense screen too
  void _handleContinue(BuildContext context) {
    if (selectedSegment == 'Friend') {
      final friendState = friendKey.currentState;
      if (friendState == null) return;

      if (friendState.isTotalPercentageValid()) {
        // TODO: Go to "SplitWithScreenFriend" to save the data
        friendState.saveAndExit(context);
      } else {
        showCustomSnackBar(
          context,
          boldText: 'Error:',
          normalText: 'Percentages must sum to 100.',
        );
      }
    } else if (selectedSegment == 'Group') {
      final groupState = groupKey.currentState;
      if (groupState == null) return;

      if (groupState.isTotalPercentageValid()) {
        // TODO: Go to "SplitWithScreenGroup" to save the data
        groupState.saveAndExit(context);
      } else {
        showCustomSnackBar(
          context,
          boldText: 'Error:',
          normalText: 'Percentages must sum to 100.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final isContinueEnabled =
        selectedSegment == 'Friend' ? isFriendValid : isGroupValid;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segment Control with Callback
              SplitWithScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: updateSegment,
              ),
              const SizedBox(height: 12),

              // Friend or Group view
              if (selectedSegment == 'Friend')
                SplitWithScreenFriend(
                  key: friendKey,
                  transactionId: widget.transactionId,
                  isReadOnly: widget.isReadOnly,
                  onValidityChanged: (valid) {
                    setState(() {
                      isFriendValid = valid;
                    });
                  },
                )
              else
                SplitWithScreenGroup(
                  key: groupKey,
                  transactionId: widget.transactionId,
                  isReadOnly: widget.isReadOnly,
                  onValidityChanged: (valid) {
                    setState(() {
                      isGroupValid = valid;
                    });
                  },
                ),

              const SizedBox(height: 24),

              // Continue Button (only in edit mode)
              if (!widget.isReadOnly)
                GestureDetector(
                  onTap: () {
                    if (isContinueEnabled) {
                      _handleContinue(context);
                    } else {
                      showCustomSnackBar(
                        context,
                        boldText: 'Error:',
                        normalText: 'Percentages must sum to 100.',
                      );
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: !isContinueEnabled,
                    child: CustomButton(
                      label: 'Continue',
                      onPressed: () => _handleContinue(context),
                      state: isContinueEnabled
                          ? ButtonState.enabled
                          : ButtonState.disabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}