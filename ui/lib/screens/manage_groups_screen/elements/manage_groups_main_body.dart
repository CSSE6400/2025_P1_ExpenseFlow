import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/manage_groups_screen/elements/manage_groups_create.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
// Elements
import 'manage_groups_segment_control.dart';
import 'manage_groups_list.dart';
import 'manage_groups_find.dart';

class ManageGroupsMainBody extends StatefulWidget {
  const ManageGroupsMainBody({super.key});

  @override
  State<ManageGroupsMainBody> createState() => _ManageGroupsMainBodyState();
}

class _ManageGroupsMainBodyState extends State<ManageGroupsMainBody> {
  String selectedSegment = 'Groups';

  void _onSegmentChanged(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
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
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segment Control
              ManageGroupsSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: _onSegmentChanged,
              ),
              const SizedBox(height: 12),

              if (selectedSegment == 'Groups') ...[
                const ManageGroupsList(),
              ] else if (selectedSegment == 'Find') ...[
                const ManageGroupsFind(),
              ] else if (selectedSegment == 'Create') ...[
                const AddExpenseScreenMainBody(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}