import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/custom_divider.dart';
import 'package:flutter_frontend/common/icon_maker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';

// Group Member class
class GroupMember {
  String name;
  String uuid;
  String percentage;
  bool checked;
  bool disabled;
  final TextEditingController controller;

  GroupMember({
    required this.name,
    required this.uuid,
    required this.percentage,
    required this.checked,
    required this.disabled,
  }) : controller = TextEditingController(text: percentage);
}

// Group class
class Group {
  String name;
  List<GroupMember> members;
  bool isSelected;
  bool isExpanded;
  String uuid;

  Group({
    required this.uuid,
    required this.name,
    required this.members,
    this.isSelected = false,
    this.isExpanded = false,
  });
}

class SplitWithScreenGroup extends StatefulWidget {
  final void Function(bool isValid)? onValidityChanged;
  final String? transactionId;
  final bool isReadOnly;

  const SplitWithScreenGroup({
    super.key,
    this.transactionId,
    this.isReadOnly = false,
    this.onValidityChanged,
  });

  @override
  State<SplitWithScreenGroup> createState() => SplitWithScreenGroupState();
}

class SplitWithScreenGroupState extends State<SplitWithScreenGroup> {
  List<Group> allGroups = [];
  List<Group> filteredGroups = [];
  final Logger _logger = Logger("SplitWithGroup");

  @override
  void initState() {
    super.initState();

    // Initialize groups
    _fetchGroups();
    // allGroups = getUserGroups
    // allGroups = [
    //   Group(uuid: '1', name: 'Flatmates', members: _generateMembers()),
    //   Group(uuid: '2', name: 'Project Team', members: _generateMembers()),
    //   Group(uuid: '3', name: 'Family', members: _generateMembers()),
    // ];

    //filteredGroups = List.from(allGroups);

    // Default: first group selected & expanded
    if (allGroups.isNotEmpty) {
      allGroups[0].isSelected = true;
      allGroups[0].isExpanded = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged?.call(isTotalPercentageValid());
    });
  }

  Future<void> _fetchGroups() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.groupApi.getUserGroups();
      allGroups = [];

      for (final group in userReads) {
      final members = await _generateMembers(group.groupId);
      allGroups.add(Group(
        name: '@${group.name}',
        members: members,
        uuid: group.groupId,
      ));
      }

      if (allGroups.isEmpty) { 
        _logger.info("User has no groups"); 
      }

      setState(() {
        filteredGroups = List.from(allGroups);
      });
    } on ApiException catch (e) {
      _logger.warning("API exception while fetching friends: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load friends",
      );
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
    }
  }

  Future<List<GroupMember>> _generateMembers(String groupId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.groupApi.getGroupUsers(groupId);

      final members = userReads.map((user) {
        return GroupMember(
          name: '@${user.nickname}',
          uuid: user.userId,
          percentage: '',
          checked: false,
          disabled: false,
        );
      }).toList();

      // Add the 'You' member
      members.insert(
        0,
        GroupMember(
          name: 'You',
          uuid: '1',
          percentage: '100',
          checked: true,
          disabled: false,
        ),
      );

      return members;
    } catch (e) {
      _logger.warning("Failed to fetch group members: $e");
      showCustomSnackBar(context, normalText: "Failed to load group members");
      return [
        GroupMember(name: 'You', percentage: '100', checked: true, disabled: false, uuid: '1')
      ];
    }
  }

  // Select a group and update its state
  void _selectGroup(int index) {
    if (widget.isReadOnly) return;

    setState(() {
      for (int i = 0; i < allGroups.length; i++) {
        final isCurrent = i == index;
        allGroups[i].isSelected = isCurrent;
        allGroups[i].isExpanded = isCurrent;

        if (!isCurrent) {
          for (var member in allGroups[i].members) {
            if (member.name == 'You') {
              member.checked = true;
              member.percentage = '100';
              member.controller.text = '100';
            } else {
              member.checked = false;
              member.percentage = '';
              member.controller.text = '';
            }
          }
        }
      }

      widget.onValidityChanged?.call(isTotalPercentageValid());
    });
  }

  // Check if the total percentage of selected members is valid (100%)
  bool isTotalPercentageValid() {
    final expandedGroup =
        allGroups.firstWhere((g) => g.isExpanded, orElse: () => allGroups[0]);
    final members = expandedGroup.members.where((m) => m.checked || m.name == 'You');
    final total = members.fold<double>(
      0,
      (sum, m) => sum + (double.tryParse(m.percentage) ?? 0),
    );
    return total == 100;
  }

  // Save group and member splits, then exit
  void saveAndExit(BuildContext context) {
    // TODO: Save group + member splits (and laod them in if needed)
    Navigator.pop(context);
  }

  // Toggle member selection and update percentage
  void _toggleMemberSelection(Group group, GroupMember member) {
    if (widget.isReadOnly || member.disabled || member.name == 'You') return;

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

      widget.onValidityChanged?.call(isTotalPercentageValid());
    });
  }

  // Filter groups based on search query
  void _filterGroups(String query) {
    setState(() {
      filteredGroups = allGroups
          .where((group) => group.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
          search.SearchBar(
            hintText: 'Search groups',
            onChanged: _filterGroups,
          ),
          const SizedBox(height: 16),

          ...filteredGroups.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _selectGroup(allGroups.indexOf(group)),
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
                            color: group.isSelected
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
                  CustomDivider(),

                  ...[
                    // sort group members: 'You' → selected → unselected
                    ...[
                      group.members.firstWhere((m) => m.name == 'You'),
                      ...group.members
                          .where((m) => m.name != 'You' && m.checked)
                          ,
                      ...group.members
                          .where((m) => m.name != 'You' && !m.checked)
                          ,
                    ].map((member) {
                      return GestureDetector(
                        onTap: () => _toggleMemberSelection(group, member),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: proportionalSizes.scaleHeight(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Username
                              Text(
                                member.name,
                                style: GoogleFonts.roboto(
                                  fontSize: proportionalSizes.scaleHeight(16),
                                  color: member.name == 'You'
                                      ? textColor
                                      : member.checked
                                          ? textColor
                                          : ColorPalette.secondaryText,
                                ),
                              ),

                              // Checkbox + percentage field
                              Row(
                                children: [
                                  if (member.checked || member.name == 'You')
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: proportionalSizes.scaleWidth(6)),
                                      child: IconMaker(
                                        assetPath: 'assets/icons/check_nofilled.png',
                                      ),
                                    ),
                                  Container(
                                    width: proportionalSizes.scaleWidth(70),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: proportionalSizes.scaleWidth(8),
                                      vertical: proportionalSizes.scaleHeight(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: (member.checked || member.name == 'You')
                                          ? ColorPalette.secondaryText.withAlpha(100)
                                          : textColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(
                                        proportionalSizes.scaleWidth(6),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: member.controller,
                                      enabled: !widget.isReadOnly && (member.checked || member.name == 'You'),
                                      keyboardType: TextInputType.number,
                                      onChanged: widget.isReadOnly
                                        ? null
                                        : (value) {
                                            setState(() {
                                              member.percentage = value;
                                              widget.onValidityChanged?.call(isTotalPercentageValid());
                                            });
                                          },
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        fontSize: proportionalSizes.scaleHeight(14),
                                        color: (member.checked || member.name == 'You')
                                            ? textColor
                                            : ColorPalette.secondaryText,
                                      ),
                                      decoration: const InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        suffixText: '%',
                                        suffixStyle: TextStyle(color: Color(0xFF0F2F63)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 12),
                ]
              ],
            );
          }),
        ],
      ),
    );
  }
}