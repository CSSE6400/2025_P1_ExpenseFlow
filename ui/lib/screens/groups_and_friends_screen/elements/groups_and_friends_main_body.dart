import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import 'groups_and_friends_segment_control.dart';

class GroupsAndFriendsMainBody extends StatefulWidget {
  const GroupsAndFriendsMainBody({super.key});

  @override
  State<GroupsAndFriendsMainBody> createState() =>
      _GroupsAndFriendsMainBodyState();
}

class _GroupsAndFriendsMainBodyState extends State<GroupsAndFriendsMainBody> {
  String selectedSegment = 'Friends';

  void updateSegment(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
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
              // Segment Control
              GroupsAndFriendsSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: updateSegment,
              ),
              const SizedBox(height: 12),

              if (selectedSegment == 'Friends') ...[
                // TODO: Insert Friends View here
              ]

              else ...[
                // TODO: Insert Groups View here
              ],
            ],
          ),
        ),
      ),
    );
  }
}