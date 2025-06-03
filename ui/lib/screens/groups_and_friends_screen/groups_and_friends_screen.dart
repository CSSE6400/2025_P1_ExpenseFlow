import 'package:flutter_frontend/common/app_bar.dart' show AppBarWidget;
import 'package:flutter_frontend/common/color_palette.dart' show ColorPalette;
import 'package:flutter_frontend/common/dialogs/app_dialog_box.dart'
    show AppDialogBox;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/friend_list.dart'
    show FriendsListView;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/group_list.dart'
    show GroupsListView;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/groups_and_friends_segment_control.dart'
    show GroupsAndFriendsSegmentControl;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/types.dart'
    show Friend, FriendRequest, FriendRequestViewStatus, Group;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart';
import '../../../common/search_bar.dart' as search;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';

class GroupsAndFriendsScreen extends StatefulWidget {
  const GroupsAndFriendsScreen({super.key});

  @override
  State<GroupsAndFriendsScreen> createState() => _GroupsAndFriendsScreenState();
}

class _GroupsAndFriendsScreenState extends State<GroupsAndFriendsScreen> {
  final Logger _logger = Logger("GroupsAndFriendsScreen");
  String _selected = 'Groups';
  String _searchQuery = '';
  List<Group> _groups = [];
  List<FriendRequest> _friends = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupsAndFriends();
  }

  Future<void> _fetchGroupsAndFriends() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userGroups = await apiService.groupApi.getUserGroups();

      setState(() {
        _groups =
            userGroups
                .map(
                  (g) => Group(
                    name: '@${g.name}',
                    groupId: g.groupId,
                    description: g.description,
                  ),
                )
                .toList();
      });

      final userFriends = await apiService.friendApi.getFriends();
      final userReadsSent = await apiService.friendApi.getSentFriendRequests();
      final userReadsIncoming =
          await apiService.friendApi.getReceivedFriendRequests();

      final allFriends = [
        ...userFriends.map(
          (f) => FriendRequest(
            friend: Friend(
              firstName: f.firstName,
              lastName: f.lastName,
              nickname: f.nickname,
              userId: f.userId,
            ),
            status: FriendRequestViewStatus.friend,
          ),
        ),
        ...userReadsSent.map(
          (f) => FriendRequest(
            friend: Friend(
              firstName: f.firstName,
              lastName: f.lastName,
              nickname: f.nickname,
              userId: f.userId,
            ),
            status: FriendRequestViewStatus.sent,
          ),
        ),
        ...userReadsIncoming.map(
          (f) => FriendRequest(
            friend: Friend(
              firstName: f.firstName,
              lastName: f.lastName,
              nickname: f.nickname,
              userId: f.userId,
            ),
            status: FriendRequestViewStatus.incoming,
          ),
        ),
      ];

      setState(() {
        _friends = allFriends;
        _loading = false;
      });
    } catch (e) {
      _logger.warning("Failed to fetch data: $e");
      if (!mounted) return;
      showCustomSnackBar(
        context,
        normalText: "Failed to load groups or friends",
      );
      setState(() => _loading = false);
    }
  }

  void _onAccepted(FriendRequest request) async {
    if (request.status == FriendRequestViewStatus.sent ||
        request.status == FriendRequestViewStatus.friend) {
      _logger.info(
        "Friend request already sent or user is already a friend: ${request.friend.nickname}",
      );
      return;
    }
    await AppDialogBox.show(
      context,
      heading: 'Accept Friend Request',
      description:
          'Do you want to accept a friend request from ${request.friend.nickname}?',
      buttonCount: 2,
      button2Text: 'Yes',
      onButton2Pressed: () async {
        Navigator.of(context).pop();
        final apiService = Provider.of<ApiService>(context, listen: false);
        try {
          final result = await apiService.friendApi
              .sendAcceptFriendRequestNickname(request.friend.nickname);

          if (result != null) {
            setState(() {
              _friends.removeWhere(
                (f) =>
                    f.friend.userId == request.friend.userId &&
                    f.status == FriendRequestViewStatus.incoming,
              );
            });

            setState(() {
              _friends.add(
                FriendRequest(
                  friend: request.friend,
                  status: FriendRequestViewStatus.friend,
                ),
              );
            });

            if (!mounted) return;
            showCustomSnackBar(
              context,
              normalText:
                  'Friend request accepted from ${request.friend.nickname}',
              type: SnackBarType.success,
            );
          }
        } catch (e) {
          _logger.warning(
            "Failed to accept request from ${request.friend.nickname}: $e",
          );
          if (!mounted) return;
          showCustomSnackBar(
            context,
            normalText: 'Failed to accept friend request',
          );
        }
      },
      button1Text: 'Cancel',
      button1Color: ColorPalette.error,
      onButton1Pressed: () => Navigator.of(context).pop(),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups =
        _groups
            .where(
              (g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    final filteredFriends =
        _friends
            .where(
              (f) => f.friend.nickname.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
          backgroundColor: ColorPalette.background,
          appBar: AppBarWidget(
            screenName: 'Groups & Friends',
            showBackButton: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupsAndFriendsSegmentControl(
                  selectedSegment: _selected,
                  onSegmentChanged:
                      (value) => setState(() => _selected = value),
                ),
                const SizedBox(height: 16),
                search.SearchBar(
                  hintText: 'Search ${_selected.toLowerCase()}',
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                if (_selected == 'Groups') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomButton(
                      label: 'Create Group',
                      onPressed:
                          () => Navigator.pushNamed(context, '/create_group'),
                      state: ButtonState.enabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                  GroupsListView(groups: filteredGroups),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomButton(
                      label: 'Find Friends',
                      onPressed: () {
                        Navigator.pushNamed(context, '/manage_friends');
                      },
                      state: ButtonState.enabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                  FriendsListView(
                    friends: filteredFriends,
                    onAccepted: _onAccepted,
                  ),
                ],
              ],
            ),
          ),
        );
  }
}
