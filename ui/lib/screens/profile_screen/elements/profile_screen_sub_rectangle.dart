// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api_service.dart';
// Third-party imports
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart' show Provider;
// Common imports
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/fields/general_field.dart';
import '../../../common/custom_divider.dart';
import '../../../common/icon_maker.dart';
// import '../../../common/custom_button.dart';

class ProfileScreenSubRectangle extends StatefulWidget {
  const ProfileScreenSubRectangle({super.key});

  @override
  State<ProfileScreenSubRectangle> createState() =>
      _ProfileScreenSubRectangleState();
}

class _ProfileScreenSubRectangleState extends State<ProfileScreenSubRectangle> {
  UserRead? user;
  final Logger _logger = Logger("ProfileScreenLogger");

  @override
  void initState() {
    _fetchUser();
    super.initState();
  }

  Future<void> _fetchUser() async {
    _logger.info("Calling the API");
    final apiService = Provider.of<ApiService>(context, listen: false);
    final fetchedUser = await apiService.userApi.getCurrentUser();
    if (!mounted) return;
    if (fetchedUser == null) {
      showCustomSnackBar(
        context,
        normalText: "Unable to view profile information",
      );
      Navigator.pushNamed(context, "/");
    } else {
      setState(() {
        user = fetchedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final backgroundColor = ColorPalette.buttonText;
    final textColor = ColorPalette.primaryText;
    final buttonBackgroundColor = ColorPalette.background;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Look at TODO
    // final apiService = Provider.of<ApiService>(context, listen: false);
    // apiService.getCurrentUser();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(44)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: proportionalSizes.scaleWidth(20),
        vertical: proportionalSizes.scaleHeight(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(22),
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryText,
                ),
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),

            // Name field Might need to change this
            GeneralField(
              label: 'Name:',
              initialValue: "${user?.firstName} ${user?.lastName}",
              isEditable: false,
            ),
            CustomDivider(),

            // Username field
            GeneralField(
              label: 'Nickname:',
              initialValue: "${user?.nickname}",
              isEditable: false,
              showStatusIcon: false,
            ),
            CustomDivider(),
            // Budget field
            GeneralField(
              label: 'Monthly Budget (\$):',
              initialValue: '1000', //TODO: Add actual budget
              isEditable: false,
              showStatusIcon: false,
            ),
            SizedBox(height: proportionalSizes.scaleHeight(30)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Services',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(22),
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryText,
                ),
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(12)),
            Container(
              decoration: BoxDecoration(
                color: buttonBackgroundColor,
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(12),
                ),
              ),
              child: ListTile(
                leading: IconMaker(assetPath: 'assets/icons/user.png'),
                title: Text(
                  'Manage Friends',
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(18),
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/home',
                  ); // TODO Change to friends page
                },
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(8)),
            Container(
              decoration: BoxDecoration(
                color: buttonBackgroundColor,
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(12),
                ),
              ),
              child: ListTile(
                leading: IconMaker(assetPath: 'assets/icons/group.png'),
                title: Text(
                  'Manage Groups',
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(18),
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/home',
                  ); // TODO: Change to groups page
                },
              ),
            ),
            SizedBox(height: proportionalSizes.scaleHeight(8)),
            Container(
              decoration: BoxDecoration(
                color: buttonBackgroundColor,
                borderRadius: BorderRadius.circular(
                  proportionalSizes.scaleWidth(12),
                ),
              ),
              child: ListTile(
                leading: IconMaker(assetPath: 'assets/icons/expenses.png'),
                title: Text(
                  'Manage Budget',
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(18),
                    color: textColor,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/home',
                  ); // TODO Change to budget page
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
