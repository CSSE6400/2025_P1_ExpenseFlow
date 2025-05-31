import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';

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
  List<Group>? filteredGroups;
  final Logger _logger = Logger("GroupsAndFriendsGroupsListLogger");

  @override
  void initState() {
    super.initState();
    _fetchGroups();

    // TODO: Load groups and their payment status from backend
    // getUserGroups()
    // allGroups = [
    //   Group(name: 'Trip', isActive: true),
    //   Group(name: 'Flatmates', isActive: false),
    //   Group(name: 'Cricket Club', isActive: true),
    //   Group(name: 'Project Team X', isActive: false),
    //   Group(name: 'Birthday', isActive: true),
    //   Group(name: 'Group ABC', isActive: false),
    // ];

    // filteredGroups = List.from(allGroups)
    //   ..sort((a, b) => b.isActive ? 1 : -1); // Active groups first
  }

  Future<void> _fetchGroups() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.groupApi.getUserGroups();

      // Convert UserRead to Friend
      allGroups = userReads
          .map((group) => Group(
                name: '@${group.name}',
                isActive: true, 
              ))
          .toList();

      if (allGroups.isEmpty) { 
        _logger.info("User has no groups"); //TODO: handle when they are in no groups?
      // allGroups = [
      //   Group(name: 'Trip', isActive: true),
        // Group(name: 'Flatmates', isActive: false),
        // Group(name: 'Cricket Club', isActive: true),
        // Group(name: 'Project Team X', isActive: false),
        // Group(name: 'Birthday', isActive: true),
        // Group(name: 'Group ABC', isActive: false),
      // ];
      }

      setState(() {
        filteredGroups = List.from(allGroups)
          ..sort((a, b) => b.isActive ? 1 : -1); // Active groups first
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
    if (filteredGroups == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search groups',
          onChanged: _filterGroups,
        ),
        const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CustomButton(
                    label: 'Manage Groups',
                    onPressed: () {
                      Navigator.pushNamed(context, '/manage_groups');
                    },
                    state: ButtonState.enabled,
                    sizeType: ButtonSizeType.full,
                  ),
                ),
        const SizedBox(height: 16),
        if (allGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Center(
              child: Text(
                "You have no groups :(",
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          )
        else
        ...filteredGroups!.map((group) => Padding(
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