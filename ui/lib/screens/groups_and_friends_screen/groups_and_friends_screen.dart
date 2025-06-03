import 'package:flutter_frontend/common/app_bar.dart' show AppBarWidget;
import 'package:flutter_frontend/common/color_palette.dart' show ColorPalette;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/groups_and_friends_friend_list.dart'
    show FriendsListView;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/groups_and_friends_group_list.dart'
    show GroupsListView;
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/groups_and_friends_segment_control.dart'
    show GroupsAndFriendsSegmentControl;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart';
import '../../../common/search_bar.dart' as search;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';

class Friend {
  final String name;
  final String uuid;

  Friend({required this.name, required this.uuid});
}

class Group {
  final String name;
  final String uuid;

  Group({required this.name, required this.uuid});
}

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
  List<Friend> _friends = [];

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
      final userFriends = await apiService.friendApi.getFriends();

      setState(() {
        _groups =
            userGroups
                .map((g) => Group(name: '@${g.name}', uuid: g.groupId))
                .toList();
        _friends =
            userFriends
                .map(
                  (f) => Friend(
                    name: "${f.firstName} ${f.lastName}",
                    uuid: f.userId,
                  ),
                )
                .toList();
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
              (f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase()),
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
                      label: 'Manage Groups',
                      onPressed:
                          () => Navigator.pushNamed(context, '/manage_groups'),
                      state: ButtonState.enabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                  GroupsListView(groups: filteredGroups),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomButton(
                      label: 'Manage Friends',
                      onPressed: () {
                        Navigator.pushNamed(context, '/manage_friends');
                      },
                      state: ButtonState.enabled,
                      sizeType: ButtonSizeType.full,
                    ),
                  ),
                  FriendsListView(friends: filteredFriends),
                ],
              ],
            ),
          ),
        );
  }
}
