import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;

class Group {
  final String name;
  final bool isActive;

  Group({required this.name, required this.isActive});
}

class GroupsAndFriendsGroupList extends StatefulWidget {
  const GroupsAndFriendsGroupList({super.key});

  @override
  State<GroupsAndFriendsGroupList> createState() =>
      _GroupsAndFriendsGroupListState();
}

class _GroupsAndFriendsGroupListState
    extends State<GroupsAndFriendsGroupList> {
  late List<Group> allGroups;
  late List<Group> filteredGroups;

  @override
  void initState() {
    super.initState();

    // TODO: Load groups and their payment status from backend
    allGroups = [
      Group(name: 'Trip', isActive: true),
      Group(name: 'Flatmates', isActive: false),
      Group(name: 'Cricket Club', isActive: true),
      Group(name: 'Project Team X', isActive: false),
      Group(name: 'Birthday', isActive: true),
      Group(name: 'Group ABC', isActive: false),
    ];

    filteredGroups = List.from(allGroups)
      ..sort((a, b) => b.isActive ? 1 : -1); // Active groups first
  }

  void _filterGroups(String query) {
    setState(() {
      filteredGroups = allGroups
          .where((group) =>
              group.name.toLowerCase().contains(query.toLowerCase()))
          .toList()
        ..sort((a, b) => b.isActive ? 1 : -1); // Active groups first
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search groups',
          onChanged: _filterGroups,
        ),
        const SizedBox(height: 16),
        ...filteredGroups.map((group) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/group_expense',
                    arguments: {'groupName': group.name},
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Group name with ellipsis and underline
                    Expanded(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    // Active tag
                    if (group.isActive) ...[
                      SizedBox(width: proportionalSizes.scaleWidth(12)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: proportionalSizes.scaleHeight(4),
                          horizontal: proportionalSizes.scaleWidth(8),
                        ),
                        decoration: BoxDecoration(
                          color: ColorPalette.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            proportionalSizes.scaleWidth(6),
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.roboto(
                            color: ColorPalette.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: proportionalSizes.scaleText(14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )),
      ],
    );
  }
}