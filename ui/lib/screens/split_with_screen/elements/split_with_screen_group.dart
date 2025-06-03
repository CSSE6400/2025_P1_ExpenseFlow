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

class GroupMemberSplit {
  String name;
  String uuid;
  String percentage;
  bool checked;
  bool disabled;
  final TextEditingController controller;

  GroupMemberSplit({
    required this.name,
    required this.uuid,
    required this.percentage,
    required this.checked,
    required this.disabled,
  }) : controller = TextEditingController(text: percentage);
}

class GroupDetailed {
  String name;
  List<GroupMemberSplit> members;
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
  List<GroupDetailed> allGroups = [];
  List<GroupDetailed> filteredGroups = [];
  final Logger _logger = Logger("SplitWithGroup");

  @override
  void initState() {
    super.initState();
    _fetchGroups();

    if (allGroups.isNotEmpty) {
      // dont think this works anymore but ehh
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
        allGroups.add(
          GroupDetailed(
            name: '@${group.name}',
            members: members,
            uuid: group.groupId,
          ),
        );
      }

      if (allGroups.isEmpty) {
        _logger.info("User has no groups");
      }

      setState(() {
        filteredGroups = List.from(allGroups);
      });
    } on ApiException catch (e) {
      _logger.warning("API exception while fetching friends: ${e.message}");
      showCustomSnackBar(context, normalText: "Failed to load friends");
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(context, normalText: "Something went wrong");
    }
  }

  Future<List<GroupMemberSplit>> _generateMembers(String groupId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      _logger.info("Calling the API");
      final fetchedUser = await apiService.userApi.getCurrentUser();
      if (fetchedUser == null) {
        showCustomSnackBar(context, normalText: "Unable to get current user");
        Navigator.pushNamed(context, "/");
        return [];
      }

      final userReads = await apiService.groupApi.getGroupUsers(groupId);
      final members =
          userReads.where((user) => user.userId != fetchedUser.userId).map((
            user,
          ) {
            return GroupMemberSplit(
              name: '@${user.nickname}',
              uuid: user.userId,
              percentage: '',
              checked: false,
              disabled: false,
            );
          }).toList();

      members.insert(
        0,
        GroupMemberSplit(
          name: 'You',
          uuid: fetchedUser.userId,
          percentage: '100',
          checked: true,
          disabled: false,
        ),
      );

      return members;
    } catch (e) {
      _logger.warning("Failed to fetch group members: $e");
      showCustomSnackBar(context, normalText: "Failed to load group members");
      return [];
    }
  }

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

  bool isTotalPercentageValid() {
    final expandedGroup = allGroups.firstWhere(
      (g) => g.isExpanded,
      orElse: () => allGroups[0],
    );
    final members = expandedGroup.members.where(
      (m) => m.checked || m.name == 'You',
    );
    final total = members.fold<double>(
      0,
      (sum, m) => sum + (double.tryParse(m.percentage) ?? 0),
    );
    return total == 100;
  }

  void saveAndExit(BuildContext context) {
    // TODO: Save group + member splits (and laod them in if needed)
    Navigator.pop(context);
  }

  void _toggleMemberSelection(GroupDetailed group, GroupMemberSplit member) {
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

  void _filterGroups(String query) {
    setState(() {
      filteredGroups =
          allGroups
              .where(
                (group) =>
                    group.name.toLowerCase().contains(query.toLowerCase()),
              )
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
          search.SearchBar(hintText: 'Search groups', onChanged: _filterGroups),
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
                  CustomDivider(),

                  ...[
                    // sort group members so it is you then selected thenunselected
                    ...[
                      group.members.firstWhere((m) => m.name == 'You'),
                      ...group.members.where(
                        (m) => m.name != 'You' && m.checked,
                      ),
                      ...group.members.where(
                        (m) => m.name != 'You' && !m.checked,
                      ),
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
                              Text(
                                member.name,
                                style: GoogleFonts.roboto(
                                  fontSize: proportionalSizes.scaleHeight(16),
                                  color:
                                      member.name == 'You'
                                          ? textColor
                                          : member.checked
                                          ? textColor
                                          : ColorPalette.secondaryText,
                                ),
                              ),
                              Row(
                                children: [
                                  if (member.checked || member.name == 'You')
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: proportionalSizes.scaleWidth(6),
                                      ),
                                      child: IconMaker(
                                        assetPath:
                                            'assets/icons/check_nofilled.png',
                                      ),
                                    ),
                                  Container(
                                    width: proportionalSizes.scaleWidth(70),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: proportionalSizes.scaleWidth(
                                        8,
                                      ),
                                      vertical: proportionalSizes.scaleHeight(
                                        4,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (member.checked ||
                                                  member.name == 'You')
                                              ? ColorPalette.secondaryText
                                                  .withAlpha(100)
                                              : textColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(
                                        proportionalSizes.scaleWidth(6),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: member.controller,
                                      enabled:
                                          !widget.isReadOnly &&
                                          (member.checked ||
                                              member.name == 'You'),
                                      keyboardType: TextInputType.number,
                                      onChanged:
                                          widget.isReadOnly
                                              ? null
                                              : (value) {
                                                setState(() {
                                                  member.percentage = value;
                                                  widget.onValidityChanged?.call(
                                                    isTotalPercentageValid(),
                                                  );
                                                });
                                              },
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        fontSize: proportionalSizes.scaleHeight(
                                          14,
                                        ),
                                        color:
                                            (member.checked ||
                                                    member.name == 'You')
                                                ? textColor
                                                : ColorPalette.secondaryText,
                                      ),
                                      decoration: const InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        suffixText: '%',
                                        suffixStyle: TextStyle(
                                          color: Color(0xFF0F2F63),
                                        ),
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
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
