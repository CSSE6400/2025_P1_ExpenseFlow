import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/custom_button.dart';
import 'elements/add_friends_to_group_friends.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;

class AddFriendsScreen extends StatefulWidget {
  final List<Friend> existingFriends;
  final bool isReadOnly;

  const AddFriendsScreen({
    super.key,
    this.existingFriends = const [],
    this.isReadOnly = false,
  });

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  List<Friend> allFriends = [];
  final Logger _logger = Logger("SelectFriends");

  @override
  void initState() {
    _fetchFriends();
    super.initState();
    // allFriends = widget.existingFriends.isNotEmpty
    //   ? List.from(widget.existingFriends)
    //   : [
    //       Friend(userId: '1', name: '@alice'),
    //       Friend(userId: '2', name: '@bob'),
    //       Friend(userId: '3', name: '@charlie'),
    //       Friend(userId: '4', name: '@diana'),
    //     ];
  }

  Future<void> _fetchFriends() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.friendApi.getFriends();

      final existingIds = widget.existingFriends.map((f) => f.userId).toSet();

      setState(() {
        allFriends = userReads.map((user) {
          return Friend(
            userId: user.userId,
            name: user.nickname,
            isSelected: existingIds.contains(user.userId),
          );
        }).toList();
      });
      _logger.info("Friends is $allFriends");
    } catch (e) {
      _logger.warning("Failed to load friends: $e");
    }
  }

  void _onFriendsChanged(List<Friend> updatedFriends, bool hasChanges) {
    setState(() {
      allFriends = updatedFriends;
    });
  }

  void _saveAndReturn() {
    final selectedFriends = allFriends.where((f) => f.isSelected).toList();
    _logger.info("selectedFriends is $selectedFriends");
    _logger.info("selectedFriends length is ${selectedFriends.length}");
    Navigator.pop(context, selectedFriends);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Add Friends', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: AddFriendsScreenItem(
                  items: allFriends,
                  onItemsChanged: _onFriendsChanged,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
              if (!widget.isReadOnly)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CustomButton(
                    label: 'Confirm Friends',
                    onPressed: _saveAndReturn,
                    state: ButtonState.enabled,
                    sizeType: ButtonSizeType.full,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'Add',
        inactive: true,
      ),
    );
  }
}
