import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/group.dart' show GroupCreate;
import 'package:flutter_frontend/screens/add_friends_to_group_screen/add_friends_to_group_screen.dart';
import 'package:flutter_frontend/screens/groups_and_friends_screen/elements/groups_and_friends_friend_list.dart';
import 'package:flutter_frontend/screens/manage_groups_screen/elements/add_group_fields.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
import '../../../common/proportional_sizes.dart';
import '../../../common/custom_button.dart';


class AddGroupScreenMainBody extends StatefulWidget {
  const AddGroupScreenMainBody({super.key});

  @override
  State<AddGroupScreenMainBody> createState() => _AddGroupScreenMainBodyState();
}

class _AddGroupScreenMainBodyState extends State<AddGroupScreenMainBody> {
  bool isFormValid = false;
  GroupCreate? _currentGroup;
  final List<String> _selectedUserIds = [];
  final Logger _logger = Logger("AddGroupScreenMainBody");

  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  Future<void> _selectFriends() async {
    final selectedFriends = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFriendsScreen(),
      ),
    );

    _logger.info("selectedFriendss is: ${selectedFriends}");
    _logger.info("selectedFriends runtimeType: ${selectedFriends.runtimeType}");

    if (selectedFriends != null) {
      _logger.info("selectedFriendsss is: ${selectedFriends}");
      _logger.info(selectedFriends.map((f) => f.name).runtimeType);
      setState(() {
        _selectedUserIds.clear();
        _selectedUserIds.addAll(selectedFriends.map((f) => f.name).cast<String>());
      });
    }
  }

  void updateGroup(GroupCreate group) {
    _currentGroup = group;
  }

  Future<void> onCreateGroup() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentGroup == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }
    _logger.info("feilds valid");

    try {
      final createdGroup = await apiService.groupApi.createGroup(_currentGroup!);

      // Add current user as admin
      final currentUser = await apiService.userApi.getCurrentUser();
      if (currentUser != null) {
        await apiService.groupApi.createUpdateGroupUser(
          createdGroup.groupId,
          currentUser.userId,
          GroupRole.admin,
        );
      }

      // add other group members
      _logger.info("_selectedUserIds count is ${_selectedUserIds.length}");
      for (final userId in _selectedUserIds) {
        _logger.info("_selectedUserIds count is ${_selectedUserIds.length}");
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
        backgroundColor: Colors.green,
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
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            children: [
              AddGroupScreenFields(
                onValidityChanged: updateFormValid,
                onGroupChanged: updateGroup,
                onSelectFriends: _selectFriends,
                selectedFriendCount: _selectedUserIds.length,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(24)),
              if (_selectedUserIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected Friends:'),
                      ..._selectedUserIds.map((id) => Text(id)).toList(),
                    ],
                  ),
                ),
            
              CustomButton(
                label: 'Create Group',
                onPressed: () async {
                  if (isFormValid) {
                    await onCreateGroup();
                  }
                },
                sizeType: ButtonSizeType.full,
                state:
                    isFormValid ? ButtonState.enabled : ButtonState.disabled,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(96)),
            ],
          ),
        ),
      ),
    );
  }
}