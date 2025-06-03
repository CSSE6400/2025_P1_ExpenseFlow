import 'package:flutter/material.dart';
import 'package:flutter_frontend/types.dart' show Friend;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class FriendsListView extends StatelessWidget {
  final List<Friend> friends;

  const FriendsListView({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    if (friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            "No friends found :(",
            style: GoogleFonts.roboto(
              fontSize: proportionalSizes.scaleText(16),
              fontWeight: FontWeight.w500,
              color: ColorPalette.primaryText,
            ),
          ),
        ),
      );
    }

    return Column(
      children:
          friends.map((friend) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/friend_expense',
                    arguments: {
                      'friendName': friend.name,
                      'friendUUID': friend.userId,
                    },
                  );
                },
                child: Text(
                  friend.name,
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(18),
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primaryText,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
