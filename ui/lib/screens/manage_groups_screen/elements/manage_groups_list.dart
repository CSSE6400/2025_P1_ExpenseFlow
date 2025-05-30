import 'package:flutter/material.dart';
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

  Group({required this.name});
}

class ManageGroupsList extends StatefulWidget {
  const ManageGroupsList({super.key});

  @override
  State<ManageGroupsList> createState() => _ManageGroupsListState();
}

class _ManageGroupsListState extends State<ManageGroupsList> {
  List<Group> allGroups = [];
  late List<Group> filteredGroups;
  final Logger _logger = Logger("ManageGroupsList");

  @override
  void initState() {
    _fetchGroups();
    super.initState();

    // allGroups = [
    //   Group(name: '@abc123'),
    //   Group(name: '@xyz987'),
    //   Group(name: '@pqr456'),
    //   Group(name: '@mno789'),
    //   Group(name: '@def321'),
    //   Group(name: '@uvw654'),
    // ];

    // filteredGroups = List.from(allGroups);
  }

  void _filterGroups(String query) {
    setState(() {
      filteredGroups = allGroups
          .where((Group) =>
              Group.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchGroups() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.groupApi.getUserGroups();

      // Convert UserRead to Group
      allGroups = userReads
          .map((group) => Group(
                name: '@${group.name}',
              ))
          .toList();

    } on ApiException catch (e) {
      _logger.warning("API exception while fetching Groups: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load Groups",
      );
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
    }
    filteredGroups = List.from(allGroups);

  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search Groups',
          onChanged: _filterGroups,
        ),
        const SizedBox(height: 16),
        if (allGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Center(
              child: Text(
                "You have no Groups :(",
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          )
        else
        ...filteredGroups.map((Group) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/Group_expense',
                    arguments: {'username': Group.name},
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Group name in a flexible container with ellipsis
                    Expanded(
                      child: Text(
                        Group.name,
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
                  ],
                ),
              ),
            )),
      ],
    );
  }
}