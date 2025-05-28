import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/custom_button.dart';
import '../../../common/dialogs/app_dialog_box.dart';

class Friend {
  final String name;

  Friend({required this.name});
}

class ManageFriendsFind extends StatefulWidget {
  const ManageFriendsFind({super.key});

  @override
  State<ManageFriendsFind> createState() => _ManageFriendsFindState();
}

class _ManageFriendsFindState extends State<ManageFriendsFind> {
  late List<Friend> allUsers;
  late List<Friend> filteredUsers;
  Set<String> sentRequests = {};

  @override
  void initState() {
    super.initState();

    // TODO: Load list of all users from backend for friend search
    allUsers = [
      Friend(name: '@abc123'),
      Friend(name: '@xyz987'),
      Friend(name: '@pqr456'),
      Friend(name: '@mno789'),
      Friend(name: '@def321'),
      Friend(name: '@uvw654'),
    ];

    filteredUsers = [];
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = [];
      } else {
        filteredUsers = allUsers
            .where((user) =>
                user.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onAddFriendPressed(BuildContext context, String username) async {
    await AppDialogBox.show(
      context,
      heading: 'Send Friend Request',
      description: 'Do you want to send a friend request to $username?',
      buttonCount: 2,
      button2Text: 'Yes',
      onButton2Pressed: () {
        // Mark request as sent
        setState(() {
          sentRequests.add(username);
        });
        Navigator.of(context).pop();
        // TODO: Send the friend request to the backend here
      },
      button1Text: 'Cancel',
      button1Color: ColorPalette.error,
      onButton1Pressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search by username',
          onChanged: _filterUsers,
        ),
        const SizedBox(height: 16),

        if (filteredUsers.isEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: proportionalSizes.scaleHeight(20),
            ),
            child: Center(
              child: Text(
                'No users found',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  color: ColorPalette.secondaryText,
                ),
              ),
            ),
          )
        else
          ...filteredUsers.map((user) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Username text
                    Expanded(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          color: textColor,
                        ),
                      ),
                    ),

                    // Add button
                    CustomButton(
                      label: sentRequests.contains(user.name) ? 'Sent' : 'Add',
                      onPressed: sentRequests.contains(user.name)
                          ? () {}
                          : () => _onAddFriendPressed(context, user.name),
                      sizeType: ButtonSizeType.quarter,
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}