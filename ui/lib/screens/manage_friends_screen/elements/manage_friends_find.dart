import 'package:flutter/material.dart';
import 'package:flutter_frontend/types.dart' show Friend;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/custom_button.dart';

class ManageFriendsFind extends StatelessWidget {
  final List<Friend> filteredUsers;
  final Set<String> sentRequests;
  final void Function(String query) onQueryChanged;
  final void Function(String username) onAddFriendPressed;

  const ManageFriendsFind({
    super.key,
    required this.filteredUsers,
    required this.sentRequests,
    required this.onQueryChanged,
    required this.onAddFriendPressed,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search by username',
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 16),
        if (filteredUsers.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: proportionalSizes.scaleHeight(20)),
            child: Center(
              child: Text(
                'No users found',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  color: ColorPalette.secondaryText,
                ),
              ),
            ),
          )
        else
          ...filteredUsers.map(
            (user) => Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalSizes.scaleText(18),
                        color: textColor,
                      ),
                    ),
                  ),
                  CustomButton(
                    label: sentRequests.contains(user.name) ? 'Sent' : 'Add',
                    onPressed:
                        () =>
                            sentRequests.contains(user.name)
                                ? null
                                : () => onAddFriendPressed(user.name),
                    sizeType: ButtonSizeType.quarter,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
