import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;

class Friend {
  final String name;
  final bool isActive;

  Friend({required this.name, required this.isActive});
}

class GroupsAndFriendsFriendList extends StatefulWidget {
  const GroupsAndFriendsFriendList({super.key});

  @override
  State<GroupsAndFriendsFriendList> createState() =>
      _GroupsAndFriendsFriendListState();
}

class _GroupsAndFriendsFriendListState
    extends State<GroupsAndFriendsFriendList> {
  late List<Friend> allFriends;
  late List<Friend> filteredFriends;

  @override
  void initState() {
    super.initState();

    // TODO: Load friends and their payment status from backend
    allFriends = [
      Friend(name: '@abc123', isActive: true),
      Friend(name: '@xyz987', isActive: false),
      Friend(name: '@pqr456', isActive: true),
      Friend(name: '@mno789', isActive: false),
      Friend(name: '@def321', isActive: false),
      Friend(name: '@uvw654', isActive: true),
    ];

    filteredFriends = List.from(allFriends)
      ..sort((a, b) => b.isActive ? 1 : -1); // Active friends first

  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends = allFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(query.toLowerCase()))
          .toList()
        ..sort((a, b) => b.isActive ? 1 : -1); // Active friends first
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
          hintText: 'Search friends',
          onChanged: _filterFriends,
        ),
        const SizedBox(height: 16),
        ...filteredFriends.map((friend) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/friend_expense',
                    arguments: {'username': friend.name},
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Friend name in a flexible container with ellipsis
                    Expanded(
                      child: Text(
                        friend.name,
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

                    // Gap between name and tag
                    if (friend.isActive) ...[
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