import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/custom_button.dart';
import '../../../common/dialogs/app_dialog_box.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';

class Friend {
  final String name;
  final String userId;

  Friend({required this.name, required this.userId});
}

class ManageFriendsFind extends StatefulWidget {
  const ManageFriendsFind({super.key});

  @override
  State<ManageFriendsFind> createState() => _ManageFriendsFindState();
}

class _ManageFriendsFindState extends State<ManageFriendsFind> {
  List<Friend> allUsers = [];
  List<Friend> filteredUsers = [];
  Set<String> sentRequests = {};
  final Logger _logger = Logger("ManageFriendsFind");

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
    
    // // TODO: Load list of all users from backend for friend search
    // allUsers = [
    //   Friend(name: '@abc123'),
    //   Friend(name: '@xyz987'),
    //   Friend(name: '@pqr456'),
    //   Friend(name: '@mno789'),
    //   Friend(name: '@def321'),
    //   Friend(name: '@uvw654'),
    // ];

    // filteredUsers = [];
  }

  Future<void> _fetchAllUsers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final allUserReads = await apiService.userApi.getAllUsers();
      final currentUser = await apiService.userApi.getCurrentUser();
      final sentRequestsUsers = await apiService.friendApi.getSentFriendRequests();
      final currentFriends = await apiService.friendApi.getFriends();
      final currentUserId = currentUser?.userId;
      final sentRequestIds = sentRequestsUsers.map((user) => user.userId).toSet();
      final currentFriendsIds = currentFriends.map((user) => user.userId).toSet();

      final filtered = allUserReads.where((user) {
        return user.userId != currentUserId 
            && !sentRequestIds.contains(user.userId) 
            && !currentFriendsIds.contains(user.userId);
      }).toList();

      setState(() {
        allUsers = filtered
            .map((user) => Friend(
                  name: '@${user.nickname}',
                  userId: user.userId,
                ))
            .toList();
        filteredUsers = allUsers;
      });
    } on ApiException catch (e) {
      _logger.warning("API exception while fetching friends: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load friends",
      );
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
    }
    filteredUsers = allUsers;

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
      onButton2Pressed: () async {
        Navigator.of(context).pop();

        final apiService = Provider.of<ApiService>(context, listen: false);
        final nickname = username.replaceFirst('@', '');

        try {
          final result = await apiService.friendApi.sendAcceptFriendRequestNickname(nickname);
          if (result != null) {
            setState(() {
              sentRequests.add(username);
            });
            showCustomSnackBar(context, normalText: 'Friend request sent to $username');
          } else {
            showCustomSnackBar(context, normalText: 'User not found.');
          }
        } on ApiException catch (e) {
          _logger.warning("API exception sending request to $username: ${e.message}");
          showCustomSnackBar(context, normalText: 'Failed to send friend request');
        } catch (e) {
          _logger.severe("Unexpected error: $e");
          showCustomSnackBar(context, normalText: 'Something went wrong');
        }
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