import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';

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
  List<Friend> allFriends = [];
  late List<Friend> filteredFriends;
  final Logger _logger = Logger("ManageFriendsList");

  @override
  void initState() {
    _fetchFriends();
    super.initState();

    // allFriends = [
    //   Friend(name: '@abc123'),
    //   Friend(name: '@xyz987'),
    //   Friend(name: '@pqr456'),
    //   Friend(name: '@mno789'),
    //   Friend(name: '@def321'),
    //   Friend(name: '@uvw654'),
    // ];

    // filteredFriends = List.from(allFriends);
  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends = allFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchFriends() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.friendApi.getFriends();

      // Convert UserRead to Friend
      allFriends = userReads
          .map((user) => Friend(
                name: '@${user.firstName}',
              ))
          .toList();

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
    filteredFriends = List.from(allFriends);

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
        if (allFriends.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Center(
              child: Text(
                "You have no friends :(",
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          )
        else
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