import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart';
import '../../../common/custom_button.dart';
import 'split_with_screen_segment_control.dart';
import 'split_with_screen_friend.dart';
import 'split_with_screen_group.dart';

class SplitWithScreenMainBody extends StatefulWidget {
  const SplitWithScreenMainBody({super.key});

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

  void updateSegment(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

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
                  onValidityChanged: (valid) {
                    setState(() {
                      isFriendValid = valid;
                    });
                  },
                )
              else
                SplitWithScreenGroup(
                  key: groupKey,
                  onValidityChanged: (valid) {
                    setState(() {
                      isGroupValid = valid;
                    });
                  },
                ),

              const SizedBox(height: 24),

              // Continue Button
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