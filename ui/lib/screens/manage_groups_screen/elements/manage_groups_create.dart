import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/enums.dart';
import 'package:flutter_frontend/models/group.dart' show GroupCreate;
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

  void updateGroup(GroupCreate group) {
    _currentGroup = group;
  }

  Future<void> onCreateGroup() async {
  final apiService = Provider.of<ApiService>(context, listen: false);

  if (_currentGroup == null) {
    showCustomSnackBar(context, normalText: "Please fill in all fields");
    return;
  }

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

    // Add other selected members
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
              ),
              SizedBox(height: proportionalSizes.scaleHeight(24)),
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


// Should make group and immediately add the current user (look at gpt)
// THen make add users screen