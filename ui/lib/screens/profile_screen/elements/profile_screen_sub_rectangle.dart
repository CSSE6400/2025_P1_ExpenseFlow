// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/custom_button.dart'
    show ButtonSizeType, ButtonState, CustomButton;
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/user.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:flutter_frontend/services/auth_service.dart' show AuthService;
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

  bool isEditingBudget = false;
  late TextEditingController _budgetController;
  String? _editedBudget;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _budgetController = TextEditingController();
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
        _budgetController.text = user?.budget.toString() ?? "";
        _editedBudget = user?.budget.toString();
      });
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _toggleEditBudget() async {
    if (isEditingBudget) {
      if (_editedBudget != user?.budget.toString()) {
        final number = int.parse(_editedBudget!);
        final apiService = Provider.of<ApiService>(context, listen: false);

        try {
          await apiService.userApi.updateUser(UserUpdate(budget: number));
          if (!mounted) return;
          showCustomSnackBar(
            context,
            normalText: "Successfully updated budget",
            type: SnackBarType.success,
          );
        } catch (e) {
          _logger.info(e);
          if (!mounted) return;
          showCustomSnackBar(
            context,
            normalText: "Unable to update user budget.",
          );
        }
      }
    }

    // Now update the state after the async work is done
    if (mounted) {
      setState(() {
        isEditingBudget = !isEditingBudget;
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeneralField(
                  label: 'Monthly Budget (\$):',
                  controller: _budgetController,
                  isEditable: isEditingBudget,
                  showStatusIcon: isEditingBudget,
                  inputRules: [InputRuleType.numericOnly],
                  validationRule: (value) {
                    final number = double.tryParse(value.trim());
                    return number != null && number > 0;
                  },
                  onChanged: (value) {
                    final num = int.tryParse(value.trim());
                    if (num != null) {
                      setState(() {
                        _editedBudget = num.toString();
                      });
                    }
                  },
                ),
                SizedBox(height: proportionalSizes.scaleHeight(8)),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    label: isEditingBudget ? "Save New Budget" : "Edit Budget",
                    onPressed: _toggleEditBudget,
                    sizeType: ButtonSizeType.full,
                    state:
                        !isEditingBudget ||
                                _editedBudget != user?.budget.toString()
                            ? ButtonState.enabled
                            : ButtonState.disabled,
                  ),
                ),
              ],
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
                  Navigator.pushNamed(context, '/manage_friends');
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
                  Navigator.pushNamed(context, '/manage_groups');
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
                leading: IconMaker(
                  assetPath: 'assets/icons/exit.png',
                  color: ColorPalette.error,
                ),
                title: Text(
                  'Log Out',
                  style: GoogleFonts.roboto(
                    fontSize: proportionalSizes.scaleText(18),
                    color: ColorPalette.error,
                  ),
                ),
                onTap: () async {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  await authService.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
