// // Flutter imports
// import 'package:flutter/material.dart';
// // Third-party imports
// import 'package:google_fonts/google_fonts.dart';
// // Common imports
// import '../../../common/color_palette.dart';
// import '../../../common/proportional_sizes.dart';
// import '../../../common/fields/general_field.dart';
// import '../../../common/custom_divider.dart';

// class ProfileScreenSubRectangleLower extends StatefulWidget {
//   const ProfileScreenSubRectangleLower({super.key});

//   @override
//   State<ProfileScreenSubRectangleLower> createState() =>
//       _ProfileScreenSubRectangleLowerState();
// }

// class _ProfileScreenSubRectangleLowerState
//     extends State<ProfileScreenSubRectangleLower> {
//   bool isBudgetValid = false;

//   bool get isFormValid => isBudgetValid;

//   void updateBudgetValidity(bool isValid) {
//     setState(() => isBudgetValid = isValid);
//   }

//   Future <void> onSave() async {
//     // TODO: Handle save functionality, leaving for updating budget
//     Navigator.pushNamed(context, '/home');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final proportionalSizes = ProportionalSizes(context: context);
//     final backgroundColor = ColorPalette.buttonText;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(proportionalSizes.scaleWidth(44)),
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: proportionalSizes.scaleWidth(20),
//         vertical: proportionalSizes.scaleHeight(20),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Heading text
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Account',
//                 style: GoogleFonts.roboto(
//                   fontSize: proportionalSizes.scaleText(22),
//                   fontWeight: FontWeight.bold,
//                   color: ColorPalette.primaryText,
//                 ),
//               ),
//             ),
//             SizedBox(height: proportionalSizes.scaleHeight(12)),

//             // Name field Might need to change this
//             GeneralField(
//               label: 'Name:',
//               initialValue: 'ABC', // TODO: make this actual username
//               isEditable: false,
//             ),
//             CustomDivider(),

//             // Username field
//             GeneralField(
//               label: 'Username:',
//               initialValue: 'user_name',
//               isEditable: false,
//               showStatusIcon: false,
//             ),
//             CustomDivider(),

//             // Budget field
//             GeneralField(
//               label: 'Monthly Budget (\$):',
//               initialValue: '1000',
//               isEditable: false,
//               showStatusIcon: false,
//             ),
//             SizedBox(height: proportionalSizes.scaleHeight(24)),

//             // // Save button
//             // CustomButton(
//             //   label: 'Save',
//             //   onPressed: isFormValid ? onSave : () {},
//             //   sizeType: ButtonSizeType.full,
//             //   state:
//             //       isFormValid ? ButtonState.enabled : ButtonState.disabled,
//             // ),

//             // SizedBox(height: proportionalSizes.scaleHeight(96), width: proportionalSizes.scaleWidth(1)),
//           ],
//         ),
//       ),
//     );
//   }
// }