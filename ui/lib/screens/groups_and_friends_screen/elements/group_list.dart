import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/group.dart' show GroupRead;
import 'package:google_fonts/google_fonts.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/color_palette.dart';

class GroupsListView extends StatelessWidget {
  final List<GroupRead> groups;

  const GroupsListView({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

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
                    '/view_group',
                    arguments: {'groupId': group.groupId},
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: proportionalSizes.scaleWidth(12)),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
