import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

import 'package:flutter_frontend/common/app_bar.dart';
import 'package:flutter_frontend/common/bottom_nav_bar.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/custom_button.dart';
import 'package:flutter_frontend/common/proportional_sizes.dart';
import 'package:flutter_frontend/common/snack_bar.dart';

import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/group.dart' show GroupCreate;
import 'package:flutter_frontend/screens/add_friends_to_group_screen/add_friends_to_group_screen.dart';
import 'package:flutter_frontend/screens/create_group_screen/elements/add_group_fields.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/types.dart' show Friend;

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final Logger _logger = Logger("CreateGroupScreen");

  final List<String> _selectedUserIds = [];
  List<Friend> _selectedFriends = [];
  GroupCreate? _currentGroup;
  bool _isFormValid = false;

  void _updateFormValid(bool isFieldsValid) {
    setState(() {
      _isFormValid = isFieldsValid && _selectedUserIds.isNotEmpty;
    });
  }

  void _updateGroup(GroupCreate group) {
    _currentGroup = group;
  }

  Future<void> _selectFriends() async {
    final selectedFriends = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFriendsScreen(existingFriends: _selectedFriends),
      ),
    );

    _logger.info("selectedFriends is: $selectedFriends");

    if (selectedFriends != null) {
      setState(() {
        _selectedFriends = List<Friend>.from(selectedFriends);
        _selectedUserIds
          ..clear()
          ..addAll(_selectedFriends.map((f) => f.userId));
      });
      _updateFormValid(_isFormValid);
    }
  }

  Future<void> _onCreateGroup() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentGroup == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }

    _logger.info("Creating group...");

    try {
      final createdGroup = await apiService.groupApi.createGroup(
        _currentGroup!,
      );

      for (final userId in _selectedUserIds) {
        await apiService.groupApi.createUpdateGroupUser(
          createdGroup.groupId,
          userId,
          GroupRole.user,
        );
      }

      if (!mounted) return;
      showCustomSnackBar(
        context,
        normalText: "Group created successfully",
        type: SnackBarType.success,
      );
      Navigator.pushNamed(context, '/');
    } catch (e) {
      _logger.severe("Failed to create group", e);
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Failed to create group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = ProportionalSizes(context: context);

    return Scaffold(
      backgroundColor: ColorPalette.background,
      appBar: AppBarWidget(screenName: 'Create Group', showBackButton: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.scaleWidth(20),
              vertical: sizes.scaleHeight(20),
            ),
            child: Column(
              children: [
                AddGroupScreenFields(
                  onValidityChanged: _updateFormValid,
                  onGroupChanged: _updateGroup,
                  onSelectFriends: _selectFriends,
                  selectedFriendCount: _selectedUserIds.length,
                  selectedFriends: _selectedFriends,
                ),
                CustomButton(
                  label: 'Create Group',
                  onPressed: _isFormValid ? () => _onCreateGroup() : () {},
                  sizeType: ButtonSizeType.full,
                  state:
                      _isFormValid ? ButtonState.enabled : ButtonState.disabled,
                ),
                SizedBox(height: sizes.scaleHeight(96)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentScreen: 'CreateGroup',
        inactive: false,
      ),
    );
  }
}
