import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/fields/general_field.dart'
    show GeneralField;
import 'package:flutter_frontend/common/proportional_sizes.dart'
    show ProportionalSizes;
import '../../../common/custom_button.dart'; // adjust the import to your project structure

class GroupDescriptionEditor extends StatefulWidget {
  final String description;
  final ValueChanged<String> onSave;

  const GroupDescriptionEditor({
    super.key,
    required this.description,
    required this.onSave,
  });

  @override
  State<GroupDescriptionEditor> createState() => _GroupDescriptionEditorState();
}

class _GroupDescriptionEditorState extends State<GroupDescriptionEditor> {
  late bool isEditing;
  late TextEditingController _controller;
  String? _editedDescription;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    _controller = TextEditingController(text: widget.description);
    _editedDescription = widget.description;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditDescription() async {
    if (isEditing) {
      // If currently editing, save only if changes made and description not empty
      if (_editedDescription != widget.description &&
          _editedDescription != null &&
          _editedDescription!.trim().isNotEmpty) {
        widget.onSave(_editedDescription!);
      }
    }

    if (mounted) {
      setState(() {
        // Toggle editing state
        isEditing = !isEditing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GeneralField(
          label: 'Description',
          controller: _controller,
          isEditable: isEditing,
          validationRule: (value) {
            return value.trim().isEmpty;
          },
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
            label: isEditing ? "Save New Description" : "Edit Description",
            onPressed: _toggleEditDescription,
            sizeType: ButtonSizeType.full,
            state:
                !isEditing || _editedDescription != widget.description
                    ? ButtonState.enabled
                    : ButtonState.disabled,
          ),
        ),
      ],
    );
  }
}
