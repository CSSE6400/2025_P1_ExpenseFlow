import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/fields/general_field.dart'
    show GeneralField;
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import '../../../common/custom_button.dart';

class GroupEditor extends StatefulWidget {
  final String name;
  final String description;
  final void Function(String, String) onSave;

  const GroupEditor({
    super.key,
    required this.name,
    required this.description,
    required this.onSave,
  });

  @override
  State<GroupEditor> createState() => _GroupEditorState();
}

class _GroupEditorState extends State<GroupEditor> {
  late bool isEditing;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String? _editedName;
  String? _editedDescription;

  @override
  void initState() {
    super.initState();
    isEditing = false;

    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);

    _editedName = widget.name;
    _editedDescription = widget.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (isEditing) {
      final hasChanges =
          (_editedName != widget.name ||
              _editedDescription != widget.description);
      final isValid =
          (_editedName != null && _editedName!.trim().isNotEmpty) &&
          (_editedDescription != null && _editedDescription!.trim().isNotEmpty);

      if (hasChanges && isValid) {
        widget.onSave(_editedName!.trim(), _editedDescription!.trim());
      }
    }

    setState(() {
      isEditing = !isEditing;
    });
  }

  bool get _canSave {
    final hasChanges =
        (_editedName != widget.name ||
            _editedDescription != widget.description);
    final isValid =
        (_editedName != null && _editedName!.trim().isNotEmpty) &&
        (_editedDescription != null && _editedDescription!.trim().isNotEmpty);
    return isEditing && hasChanges && isValid;
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GeneralField(
          label: 'Name',
          controller: _nameController,
          isEditable: isEditing,
          validationRule: (value) => value.trim().isEmpty,
          onChanged: (value) {
            setState(() {
              _editedName = value;
            });
          },
        ),
        SizedBox(height: proportionalSizes.scaleHeight(8)),
        GeneralField(
          label: 'Description',
          controller: _descriptionController,
          isEditable: isEditing,
          validationRule: (value) => value.trim().isEmpty,
          onChanged: (value) {
            setState(() {
              _editedDescription = value;
            });
          },
        ),
        SizedBox(height: proportionalSizes.scaleHeight(8)),
        Align(
          alignment: Alignment.centerRight,
          child: CustomButton(
            label: isEditing ? "Save" : "Edit",
            onPressed: _toggleEdit,
            sizeType: ButtonSizeType.full,
            state:
                _canSave || !isEditing
                    ? ButtonState.enabled
                    : ButtonState.disabled,
          ),
        ),
      ],
    );
  }
}
