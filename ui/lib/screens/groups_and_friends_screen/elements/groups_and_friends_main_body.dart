import 'package:flutter/material.dart';
// Common imports
import '../../../common/proportional_sizes.dart';

class GroupsAndFriendsMainBody extends StatefulWidget {
  const GroupsAndFriendsMainBody({super.key});

  @override
  State<GroupsAndFriendsMainBody> createState() => _GroupsAndFriendsMainBodyState();
}

class _GroupsAndFriendsMainBodyState extends State<GroupsAndFriendsMainBody> {
  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            ],
          ),
        ),
      ),
    );
  }
}