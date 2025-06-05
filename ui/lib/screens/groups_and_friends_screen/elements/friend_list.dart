import 'package:flutter/material.dart';
import 'package:expenseflow/common/custom_button.dart'
    show ButtonSizeType, ButtonState, CustomButton;
import 'package:expenseflow/types.dart'
    show FriendRequest, FriendRequestViewStatus;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';

class FriendsListView extends StatelessWidget {
  final List<FriendRequest> friends;
  final void Function(FriendRequest) onAccepted;

  const FriendsListView({
    super.key,
    required this.friends,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

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
                onTap:
                    friend.status == FriendRequestViewStatus.friend
                        ? () {
                          Navigator.pushNamed(
                            context,
                            '/view_friend',
                            arguments: {'userId': friend.friend.userId},
                          );
                        }
                        : null,
                child: Row(
                  children: [
                    // Username
                    Expanded(
                      child: Text(
                        friend.friend.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          color: textColor,
                        ),
                      ),
                    ),
                    // Button
                    if (friend.status == FriendRequestViewStatus.friend)
                      CustomButton(
                        label: 'View',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/view_friend',
                            arguments: {'userId': friend.friend.userId},
                          );
                        },
                        sizeType: ButtonSizeType.quarter,
                      )
                    else if (friend.status == FriendRequestViewStatus.sent)
                      CustomButton(
                        label: 'Sent',
                        onPressed: () {},
                        state: ButtonState.disabled,
                        sizeType: ButtonSizeType.quarter,
                      )
                    else if (friend.status == FriendRequestViewStatus.incoming)
                      CustomButton(
                        label: 'Accept',
                        onPressed: () => onAccepted(friend),
                        sizeType: ButtonSizeType.quarter,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
