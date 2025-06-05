import 'package:flutter/material.dart';
import 'package:expenseflow/common/dialogs/app_dialog_box.dart'
    show AppDialogBox;
import 'package:expenseflow/common/snack_bar.dart'
    show SnackBarType, showCustomSnackBar;
import 'package:expenseflow/models/user.dart';
import 'package:expenseflow/screens/manage_friends_screen/elements/find_friends.dart'
    show ManageFriendsFind;
import 'package:expenseflow/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;

import '../../common/color_palette.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/app_bar.dart';
import '../../common/proportional_sizes.dart';

class ManageFriendsScreen extends StatefulWidget {
  const ManageFriendsScreen({super.key});

  @override
  State<ManageFriendsScreen> createState() => _ManageFriendsScreenState();
}

class _ManageFriendsScreenState extends State<ManageFriendsScreen> {
  final Logger _logger = Logger("ManageFriendsFind");

  List<UserReadMinimal> allUsers = [];
  List<UserReadMinimal> filteredUsers = [];
  Set<String> sentRequests = {};

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final allUserReads = await apiService.userApi.getAllUsers();

      final sentRequestsUsers =
          await apiService.friendApi.getSentFriendRequests();
      final currentFriends = await apiService.friendApi.getFriends();

      final sentRequestIds = sentRequestsUsers.map((u) => u.userId).toSet();
      final currentFriendsIds = currentFriends.map((u) => u.userId).toSet();

      final filtered =
          allUserReads
              .where((user) {
                return !sentRequestIds.contains(user.userId) &&
                    !currentFriendsIds.contains(user.userId);
              })
              .map(
                (user) => UserReadMinimal(
                  nickname: user.nickname,
                  userId: user.userId,
                ),
              )
              .toList();

      setState(() {
        allUsers = filtered;
        filteredUsers = filtered;
        sentRequests = sentRequestsUsers.map((u) => "@${u.nickname}").toSet();
      });
    } catch (e) {
      _logger.warning("Failed to fetch friends: $e");
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Error loading users");
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = allUsers;
      } else {
        filteredUsers =
            allUsers
                .where(
                  (u) => u.nickname.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  void _onAddFriendPressed(UserReadMinimal user) async {
    if (sentRequests.contains(user.nickname)) {
      return;
    }
    _logger.info("Adding friend: ${user.nickname}");
    await AppDialogBox.show(
      context,
      heading: 'Send Friend Request',
      description: 'Do you want to send a friend request to ${user.nickname}?',
      buttonCount: 2,
      button2Text: 'Yes',
      onButton2Pressed: () async {
        Navigator.of(context).pop();
        final apiService = Provider.of<ApiService>(context, listen: false);
        try {
          final result = await apiService.friendApi
              .sendAcceptFriendRequestNickname(user.nickname);

          if (result != null) {
            setState(() {
              sentRequests.add(user.nickname);
            });

            if (!mounted) return;
            showCustomSnackBar(
              context,
              normalText: 'Friend request sent to ${user.nickname}',
              type: SnackBarType.success,
            );
          } else {
            if (!mounted) return;
            showCustomSnackBar(context, normalText: 'User not found.');
          }
        } catch (e) {
          _logger.warning("Failed to send request to ${user.nickname}: $e");
          if (!mounted) return;
          showCustomSnackBar(
            context,
            normalText: 'Failed to send friend request',
          );
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

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Find Friends', showBackButton: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: proportionalSizes.scaleWidth(20),
              vertical: proportionalSizes.scaleHeight(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ManageFriendsFind(
                  sentRequests: sentRequests,
                  users: filteredUsers,
                  onQueryChanged: _filterUsers,
                  onAddFriendPressed: _onAddFriendPressed,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(inactive: false),
    );
  }
}
