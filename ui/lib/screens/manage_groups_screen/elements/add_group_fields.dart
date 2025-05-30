import 'package:flutter/material.dart';
import 'package:flutter_frontend/utils/string_utils.dart';
// Common imports
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/fields/date_field/date_field.dart';
import '../../../common/fields/dropdown_field.dart';
import '../../../models/group.dart';
import '../../../common/fields/custom_icon_field.dart';
import '../../../common/proportional_sizes.dart';
// import '../../../common/show_image.dart';
import '../../../common/snack_bar.dart';
import '../../add_items_screen/add_items_screen.dart';

class AddGroupScreenFields extends StatefulWidget {
  final void Function(bool isValid) onValidityChanged;
  final void Function(GroupCreate group)? onGroupChanged;

  const AddGroupScreenFields({
    super.key,
    required this.onValidityChanged,
    required this.onGroupChanged,
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

        // You can implement this later to actually select users:
        CustomIconField(
          label: 'Add Friends',
          value: '', // show selected count or names here
          hintText: 'Select friends to add',
          trailingIconPath: 'assets/icons/search.png',
          onTap: () {
            Navigator.pushNamed(context, '/select_friends'); // placeholder
          },
        ),
        CustomDivider(),

        SizedBox(height: 20),
      ],
    );
  }
}
