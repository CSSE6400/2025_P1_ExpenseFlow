import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/group.dart' show GroupCreate;
import 'package:flutter_frontend/screens/add_friends_to_group_screen/add_friends_to_group_screen.dart';
import 'package:flutter_frontend/screens/create_group_screen/elements/add_group_fields.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:flutter_frontend/types.dart' show Friend;
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
  List<Friend> _selectedFriends = [];
  final Logger _logger = Logger("AddGroupScreenMainBody");

  // void updateFormValid(bool isValid) {
  //   setState(() => isFormValid = isValid);
  // }
  void updateFormValid(bool isValidFields) {
    final isFormValidWithFriends = isValidFields && _selectedUserIds.isNotEmpty;
    setState(() => isFormValid = isFormValidWithFriends);
  }

  Future<void> _selectFriends() async {
    final selectedFriends = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddFriendsScreen(existingFriends: _selectedFriends),
      ),
    );

    _logger.info("selectedFriendss is: ${selectedFriends}");
    _logger.info("selectedFriends runtimeType: ${selectedFriends.runtimeType}");

    if (selectedFriends != null) {
      _logger.info("selectedFriendsss is: ${selectedFriends}");
      _logger.info(selectedFriends.map((f) => f.name).runtimeType);
      setState(() {
        _selectedFriends = List<Friend>.from(selectedFriends);
        _selectedUserIds
          ..clear()
          ..addAll(_selectedFriends.map((f) => f.userId));
      });
      updateFormValid(isFormValid);
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
      final createdGroup = await apiService.groupApi.createGroup(
        _currentGroup!,
      );

      // // add user that created the group. Seems that I do not need this?
      // final currentUser = await apiService.userApi.getCurrentUser();
      // if (currentUser != null) {
      //   await apiService.groupApi.createUpdateGroupUser(
      //     createdGroup.groupId,
      //     currentUser.userId,
      //     GroupRole.admin,
      //   );
      // }

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
                selectedFriends: _selectedFriends,
              ),
              CustomButton(
                label: 'Create Group',
                onPressed: () async {
                  if (isFormValid) {
                    await onCreateGroup();
                  }
                },
                sizeType: ButtonSizeType.full,
                state: isFormValid ? ButtonState.enabled : ButtonState.disabled,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(96)),
            ],
          ),
        ),
      ),
    );
  }
}
