import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import 'groups_and_friends_segment_control.dart';
import 'groups_and_friends_friend_list.dart';
import 'groups_and_friends_group_list.dart';

class GroupsAndFriendsMainBody extends StatefulWidget {
  final String selectedSegment;
  final void Function(String) onSegmentChanged;

  const GroupsAndFriendsMainBody({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  @override
  State<GroupsAndFriendsMainBody> createState() =>
      _GroupsAndFriendsMainBodyState();
}

class _GroupsAndFriendsMainBodyState extends State<GroupsAndFriendsMainBody> {
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
                selectedSegment: widget.selectedSegment,
                onSegmentChanged: widget.onSegmentChanged,
              ),
              const SizedBox(height: 12),

              if (widget.selectedSegment == 'Friends') ...[
                const GroupsAndFriendsFriendList(),
              ] else ...[
                const GroupsAndFriendsGroupList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}