import 'package:flutter/material.dart';
import 'package:flutter_frontend/types.dart' show Friend;
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../models/group.dart';
import '../../../common/fields/custom_icon_field.dart';

class AddGroupScreenFields extends StatefulWidget {
  final void Function(bool isValid) onValidityChanged;
  final void Function(GroupCreate group)? onGroupChanged;
  final VoidCallback onSelectFriends;
  final int selectedFriendCount;
  final List<Friend> selectedFriends;

  const AddGroupScreenFields({
    super.key,
    required this.onValidityChanged,
    required this.onGroupChanged,
    required this.onSelectFriends,
    required this.selectedFriendCount,
    required this.selectedFriends,
  });

  @override
  State<AddGroupScreenFields> createState() => _AddGroupScreenFieldsState();
}

class _AddGroupScreenFieldsState extends State<AddGroupScreenFields> {
  bool isNameValid = false;
  bool isDescriptionValid = false;

  String _name = "";
  String _description = "";

  void _updateField<T>(void Function() updateState) {
    setState(updateState);
    _notifyGroupChanged();
    _updateFormValidity();
  }

  void _updateFormValidity() {
    final isFormValid = isNameValid && isDescriptionValid;
    widget.onValidityChanged.call(isFormValid);
  }

  void _notifyGroupChanged() {
    final group = GroupCreate(name: _name, description: _description);
    widget.onGroupChanged?.call(group);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GeneralField(
          label: 'Name*',
          initialValue: '',
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: (isValid) {
            setState(() => isNameValid = isValid);
            _updateFormValidity();
          },
          maxLength: 50,
          onChanged: (value) => _updateField(() => _name = value),
        ),
        CustomDivider(),
        GeneralField(
          label: 'Description*',
          initialValue: '',
          isEditable: true,
          showStatusIcon: true,
          validationRule: (value) => value.trim().isNotEmpty,
          onValidityChanged: (isValid) {
            setState(() => isDescriptionValid = isValid);
            _updateFormValidity();
          },
          maxLength: 100,
          onChanged: (value) => _updateField(() => _description = value),
        ),
        CustomDivider(),

        CustomIconField(
          label: 'Add Friends',
          value: '${widget.selectedFriendCount} selected',
          hintText: 'Select friends to add',
          trailingIconPath: 'assets/icons/search.png',
          onTap: widget.onSelectFriends,
        ),
        if (widget.selectedFriends.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    widget.selectedFriends.map((friend) {
                      return Chip(
                        label: Text(friend.name),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        CustomDivider(),

        SizedBox(height: 20),
      ],
    );
  }
}
