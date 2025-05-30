import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:flutter_frontend/models/expense.dart' show ExpenseCreate;
import 'package:flutter_frontend/screens/manage_groups_screen/elements/add_group_fields.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:logging/logging.dart' show Logger;
import 'package:provider/provider.dart' show Provider;
// Third-party imports
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../../common/custom_button.dart';
// Elements
// import 'add_expense_screen_scan_receipt.dart';
// import 'add_expense_screen_fields.dart';

class AddExpenseScreenMainBody extends StatefulWidget {
  const AddExpenseScreenMainBody({super.key});

  @override
  State<AddExpenseScreenMainBody> createState() =>
      _AddExpenseScreenMainBodyState();
}

class _AddExpenseScreenMainBodyState extends State<AddExpenseScreenMainBody> {
  bool isFormValid = false;
  ExpenseCreate? _currentExpense;
  final Logger _logger = Logger("AddExpenseScreenMainBody");

  void updateFormValid(bool isValid) {
    setState(() => isFormValid = isValid);
  }

  void updateExpense(ExpenseCreate expense) {
    _currentExpense = expense;
  }

  Future<void> onAdd() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    if (_currentExpense == null) {
      showCustomSnackBar(context, normalText: "Please fill in all fields");
      return;
    }

    try {
      await apiService.expenseApi.createExpense(_currentExpense!);
      if (!mounted) return;
      showCustomSnackBar(
        context,
        normalText: "Successfully added expense",
        backgroundColor: Colors.green,
      );
      Navigator.pushNamed(context, '/');
    } catch (e) {
      _logger.severe("Failed to add expense", e);
      if (!mounted) return;
      showCustomSnackBar(context, normalText: "Failed to add expense");
    }
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: proportionalSizes.scaleWidth(20),
            vertical: proportionalSizes.scaleHeight(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              AddGroupScreenFields(
                onValidityChanged: updateFormValid,
                onExpenseChanged: updateExpense,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(24)),

              CustomButton(
                label: 'Add Expense',
                onPressed: isFormValid ? onAdd : () {},
                sizeType: ButtonSizeType.full,
                state: isFormValid ? ButtonState.enabled : ButtonState.disabled,
              ),
              SizedBox(height: proportionalSizes.scaleHeight(96)),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../../common/color_palette.dart';
// import '../../../common/proportional_sizes.dart';
// import '../../../common/search_bar.dart' as search;
// import '../../../common/custom_button.dart';
// import '../../../common/dialogs/app_dialog_box.dart';
// import 'package:flutter_frontend/services/api_service.dart';
// import 'package:provider/provider.dart' show Provider;
// import 'package:flutter_frontend/common/snack_bar.dart';
// import 'package:logging/logging.dart';

// class GroupCreate {
//   final String name;
//   final bool isIncoming;

//   GroupCreate({required this.name, required this.isIncoming});
// }

// class ManageGroupsCreate extends StatefulWidget {
//   const ManageGroupsCreate({super.key});

//   @override
//   State<ManageGroupsCreate> createState() => _ManageGroupsRequestsState();
// }

// class _ManageGroupsRequestsState extends State<ManageGroupsCreate> {
//   List<GroupCreate> allRequests = [];
//   List<GroupCreate> filteredRequests = [];
//   final Logger _logger = Logger("ManageGroupsREquestsLogger");

//   @override
//   void initState() {
//     super.initState();
//     //_fetchRequests();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final proportionalSizes = ProportionalSizes(context: context);
//     final textColor = ColorPalette.primaryText;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         search.SearchBar(
//           hintText: 'Search by username',
//           onChanged: _filterRequests,
//         ),
//         const SizedBox(height: 16),

//         if (filteredRequests.isEmpty)
//           Padding(
//             padding: EdgeInsets.only(
//               top: proportionalSizes.scaleHeight(20),
//             ),
//             child: Center(
//               child: Text(
//                 'No requests found',
//                 style: GoogleFonts.roboto(
//                   fontSize: proportionalSizes.scaleText(16),
//                   color: ColorPalette.secondaryText,
//                 ),
//               ),
//             ),
//           )
//         else
//           ...filteredRequests.map((request) => Padding(
//                 padding: EdgeInsets.symmetric(
//                   vertical: proportionalSizes.scaleHeight(8),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Username
//                     Expanded(
//                       child: Text(
//                         request.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.roboto(
//                           fontSize: proportionalSizes.scaleText(18),
//                           color: textColor,
//                         ),
//                       ),
//                     ),
//                     // Button
//                     request.isIncoming
//                         ? CustomButton(
//                             label: 'Accept',
//                             onPressed: () =>
//                                 _onAcceptRequest(context, request.name),
//                             sizeType: ButtonSizeType.quarter,
//                           )
//                         : CustomButton(
//                             label: 'Sent',
//                             onPressed: () {},
//                             state: ButtonState.disabled,
//                             sizeType: ButtonSizeType.quarter,
//                           ),
//                   ],
//                 ),
//               )),
//       ],
//     );
//   }
// }
