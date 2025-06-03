import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';
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
  List<Friend>? filteredFriends;
  final Logger _logger = Logger("GroupandFriendsFriendListLogger");

  @override
  void initState() {
    _fetchFriends();
    super.initState();
  }

  Future<void> _fetchFriends() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.friendApi.getFriends();

      setState(() {
        allFriends =
            userReads
                .map(
                  (user) => Friend(name: '@${user.nickname}', isActive: true),
                )
                .toList();
      });

      setState(() {
        filteredFriends = List.from(allFriends)
          ..sort((a, b) => b.isActive ? 1 : -1); // active friends first
      });
    } on ApiException catch (e) {
      _logger.warning("API exception while fetching friends: ${e.message}");
      showCustomSnackBar(context, normalText: "Failed to load friends");
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(context, normalText: "Something went wrong");
    }
  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends =
          allFriends
              .where(
                (friend) =>
                    friend.name.toLowerCase().contains(query.toLowerCase()),
              )
              .toList()
            ..sort((a, b) => b.isActive ? 1 : -1); // active friends first
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    if (filteredFriends == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(hintText: 'Search friends', onChanged: _filterFriends),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: CustomButton(
            label: 'Manage Friends',
            onPressed: () {
              Navigator.pushNamed(context, '/manage_friends');
            },
            state: ButtonState.enabled,
            sizeType: ButtonSizeType.full,
          ),
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
          ...filteredFriends!.map(
            (friend) => Padding(
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
                          'Friend',
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
            ),
          ),
      ],
    );
  }
}
