import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
// Elements
import 'manage_friends_segment_control.dart';
import 'manage_friends_list.dart';

class ManageFriendsMainBody extends StatefulWidget {
  const ManageFriendsMainBody({super.key});

  @override
  State<ManageFriendsMainBody> createState() => _ManageFriendsMainBodyState();
}

class _ManageFriendsMainBodyState extends State<ManageFriendsMainBody> {
  String selectedSegment = 'Friends';

  void _onSegmentChanged(String newSegment) {
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
              ManageFriendsSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: _onSegmentChanged,
              ),
              const SizedBox(height: 12),

              if (selectedSegment == 'Friends') ...[
                const ManageFriendsList(),
              ] else if (selectedSegment == 'Find') ...[
              ] else if (selectedSegment == 'Requests') ...[
              ],
            ],
          ),
        ),
      ),
    );
  }
}