import 'package:flutter/material.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/snack_bar.dart'; // for showCustomSnackBar
import '../../../common/custom_button.dart'; // for CustomButton
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

  bool isFriendValid = false;

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
    }

    // TODO: Handle 'Group' segment logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

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
                const SplitWithScreenGroup(),

              const SizedBox(height: 24),

              // Continue Button
              CustomButton(
                label: 'Continue',
                onPressed: () => _handleContinue(context),
                state: isFriendValid
                    ? ButtonState.enabled
                    : ButtonState.disabled,
                sizeType: ButtonSizeType.full,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}