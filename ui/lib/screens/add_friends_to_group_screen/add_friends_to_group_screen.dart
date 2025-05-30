import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
import '../../common/custom_button.dart';
import 'elements/add_friends_to_group_friends.dart';

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
    super.initState();
    allFriends = widget.existingFriends.isNotEmpty
      ? List.from(widget.existingFriends)
      : [
          Friend(name: '@alice'),
          Friend(name: '@bob'),
          Friend(name: '@charlie'),
          Friend(name: '@diana'),
        ];
  }

  void _onFriendsChanged(List<Friend> updatedFriends, bool hasChanges) {
    setState(() {
      allFriends = updatedFriends;
    });
  }

  void _saveAndReturn() {
    final selectedFriends = allFriends.where((f) => f.isSelected).toList();
    _logger.info("selectedFriends is ${selectedFriends}");
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
