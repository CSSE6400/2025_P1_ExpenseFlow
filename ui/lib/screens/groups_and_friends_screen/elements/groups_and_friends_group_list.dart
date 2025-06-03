import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/groups_and_friends_screen/groups_and_friends_screen.dart'
    show Group;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/color_palette.dart';

class GroupsListView extends StatelessWidget {
  final List<Group> groups;

  const GroupsListView({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            "You have no groups :(",
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
          groups.map((group) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: proportionalSizes.scaleHeight(8),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/group_expense',
                    arguments: {
                      'groupName': group.name,
                      'groupUUID': group.uuid,
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.primaryText,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: proportionalSizes.scaleWidth(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: proportionalSizes.scaleHeight(4),
                        horizontal: proportionalSizes.scaleWidth(8),
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.accent.withOpacity(0.2),
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
                ),
              ),
            );
          }).toList(),
    );
  }
}
