import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;

class Friend {
  final String name;

  Friend({required this.name});
}

class ManageFriendsList extends StatefulWidget {
  const ManageFriendsList({super.key});

  @override
  State<ManageFriendsList> createState() => _ManageFriendsListState();
}

class _ManageFriendsListState extends State<ManageFriendsList> {
  late List<Friend> allFriends;
  late List<Friend> filteredFriends;

  @override
  void initState() {
    super.initState();

    // TODO: Load friends from backend
    allFriends = [
      Friend(name: '@abc123'),
      Friend(name: '@xyz987'),
      Friend(name: '@pqr456'),
      Friend(name: '@mno789'),
      Friend(name: '@def321'),
      Friend(name: '@uvw654'),
    ];

    filteredFriends = List.from(allFriends);
  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends = allFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  ],
                ),
              ),
            )),
      ],
    );
  }
}