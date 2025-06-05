import 'package:flutter/material.dart';
import 'package:expenseflow/common/color_palette.dart';
import 'package:expenseflow/common/custom_divider.dart';
import 'package:expenseflow/common/icon_maker.dart';
import 'package:expenseflow/models/expense.dart';
import 'package:expenseflow/models/group.dart';
import 'package:expenseflow/models/user.dart' show UserRead;
import 'package:expenseflow/screens/split_with_screen/split_with_screen.dart'
    show UserSplit;
import 'package:expenseflow/widgets/user_split_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';

class GroupDetailed {
  String name;
  List<UserSplit> members;
  bool isSelected;
  bool isExpanded;
  String uuid;

  GroupDetailed({
    required this.uuid,
    required this.name,
    required this.members,
    this.isSelected = false,
    this.isExpanded = false,
  });
}

class SplitWithScreenGroup extends StatefulWidget {
  final List<GroupReadWithMembers> groups;

  final List<ExpenseItemSplitCreate> splits;
  final UserRead currentUser;
  final void Function(bool isValid) onValidityChanged;
  final Function(List<ExpenseItemSplitCreate> splits) onSplitsUpdated;
  final bool isReadOnly;
  final String? selectedGroupId;

  const SplitWithScreenGroup({
    super.key,
    required this.groups,
    required this.splits,
    required this.currentUser,
    required this.onValidityChanged,
    required this.onSplitsUpdated,
    required this.isReadOnly,
    required this.selectedGroupId,
  });

  @override
  State<SplitWithScreenGroup> createState() => SplitWithScreenGroupState();
}

class SplitWithScreenGroupState extends State<SplitWithScreenGroup> {
  List<GroupDetailed> allGroups = [];
  GroupDetailed? selectedGroup;

  GroupDetailed? getSelectedGroup() => selectedGroup;

  double? getUserProption(String userId, List<ExpenseItemSplitCreate> splits) {
    for (var split in splits) {
      if (split.userId == userId) {
        return split.proportion;
      }
    }
    return null;
  }

  final Logger _logger = Logger("SplitWithGroup");

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged.call(isTotalPercentageValid());
    });

    _logger.info("Initializing groups");

    allGroups =
        widget.groups.map((group) {
          final members =
              group.members.map((member) {
                return UserSplit(
                  name: member.nickname,
                  userId: member.userId,
                  percentage:
                      getUserProption(member.userId, widget.splits) != null
                          ? (getUserProption(member.userId, widget.splits)! *
                                  100)
                              .toStringAsFixed(0)
                          : '',
                  checked:
                      getUserProption(member.userId, widget.splits) != null,
                );
              }).toList();

          return GroupDetailed(
            uuid: group.groupId,
            name: group.name,
            members: members,
            isSelected: selectedGroup?.uuid == group.groupId,
          );
        }).toList();
  }

  void _selectGroup(GroupDetailed group) {
    _logger.info('Selecting group: ${group.name}');
    if (widget.isReadOnly) return;

    _logger.info("Not read-only, proceeding with selection");

    group.isSelected = true;

    setState(() => selectedGroup = group);

    widget.onValidityChanged.call(isTotalPercentageValid());

    // update item splits when a new group is selected
    _updateSplits();
  }

  bool isTotalPercentageValid() {
    if (selectedGroup == null) return false;

    final total = selectedGroup!.members.fold<double>(
      0,
      (sum, m) => sum + (double.tryParse(m.percentage) ?? 0),
    );

    return total == 100;
  }

  void _updateSplits() {
    _logger.info('Updating splits with current selections');
    _logger.info("Current splits: ${widget.splits}");

    final splits = <ExpenseItemSplitCreate>[];

    if (selectedGroup == null) {
      _logger.warning('No group selected, cannot update splits');
    } else {
      for (var member in selectedGroup!.members) {
        if (member.checked || member.userId == widget.currentUser.userId) {
          final percentage = double.tryParse(member.percentage) ?? 0.0;
          if (percentage > 0) {
            splits.add(
              ExpenseItemSplitCreate(
                userId: member.userId,
                proportion: percentage / 100.0,
              ),
            );
          }
        }
      }
    }

    _logger.info("Updated splits: $splits");
    widget.onSplitsUpdated(splits);
  }

  void saveAndExit(BuildContext context) {
    _logger.info('Saving splits and exiting');
    _updateSplits();
    Navigator.pop(context, widget.splits);
  }

  void _toggleMemberSelection(GroupDetailed group, UserSplit member) {
    if (widget.isReadOnly) return;

    setState(() {
      member.checked = !member.checked;

      if (member.checked && member.percentage.isEmpty) {
        member.percentage = '0';
        member.controller.text = '0';
      }

      if (!member.checked) {
        member.percentage = '';
        member.controller.text = '';
      }

      widget.onValidityChanged.call(isTotalPercentageValid());
      _updateSplits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...allGroups.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      group.isExpanded = !group.isExpanded;
                      _selectGroup(group);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: proportionalSizes.scaleHeight(8),
                    ),
                    child: Row(
                      children: [
                        Transform.rotate(
                          angle: group.isExpanded ? 4.71 : 0,
                          child: IconMaker(
                            assetPath: 'assets/icons/angle_small_right.png',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          group.name,
                          style: GoogleFonts.roboto(
                            fontSize: proportionalSizes.scaleHeight(18),
                            fontWeight: FontWeight.bold,
                            color:
                                group.isSelected
                                    ? textColor
                                    : ColorPalette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (group.isExpanded) ...[
                  const SizedBox(height: 6),
                  const CustomDivider(),
                  ...group.members.map((member) {
                    return UserSplitWidget(
                      user: member,
                      isReadOnly: widget.isReadOnly,
                      onTap: () => _toggleMemberSelection(group, member),
                      onChanged: (value) {
                        setState(() {
                          member.percentage = value;

                          final shouldBeChecked =
                              value.trim().isNotEmpty && value.trim() != '0';
                          member.checked = shouldBeChecked;

                          widget.onValidityChanged.call(
                            isTotalPercentageValid(),
                          );
                          _updateSplits();
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
