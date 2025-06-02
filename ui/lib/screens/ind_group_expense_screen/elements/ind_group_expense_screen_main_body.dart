import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/time_period_dropdown.dart';
import 'package:flutter_frontend/models/group.dart';
import 'package:logging/logging.dart';
// Common imports
import '../../../common/proportional_sizes.dart';
import '../../expenses_screen/elements/expenses_screen_segment_control.dart';
import '../elements/ind_group_expense_screen_list.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';

class GroupMember {
  final String name;
  final String? status; // null for 'You', else: 'Needs Approval', 'Approved', 'Needs Payment', 'Paid'
  final String amount;

  GroupMember({required this.name, this.status, required this.amount});
}

class Group {
  final String groupId;
  final String name;
  final String description;

  Group({required this.groupId, required this.name, required this.description});
}

class ExpenseItem {
  final String name;
  final String price;
  final String date; // iso 8601 format
  final bool active;
  final List<GroupMember> members;

  ExpenseItem({
    required this.name,
    required this.price,
    required this.date,
    required this.active,
    required this.members,
  });
}

class IndGroupExpenseScreenMainBody extends StatefulWidget {
  final String groupName;
  final String groupUUID;

  const IndGroupExpenseScreenMainBody({super.key, required this.groupName, required this.groupUUID});

  @override
  State<IndGroupExpenseScreenMainBody> createState() =>
      _IndGroupExpenseScreenMainBodyState();
}

class _IndGroupExpenseScreenMainBodyState
    extends State<IndGroupExpenseScreenMainBody> {
  String selectedSegment = 'Active';
  String selectedPeriod = 'Last 30 Days';
  late final List<ExpenseItem> allExpenses;
  //late final List<String> groupMembers;
  List<String> groupMembers = [];
  final Logger _logger = Logger("IndividualGroupScreen");
  Group group = Group(
        groupId: "loading...",
        name: "loading...",
        description: "loading...",
      );
  bool isEditingDescription = false;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _initialiseData();
    _fetchGroupMembers();

    // TODO: Replace with actual data from your database
    // Shouldn't "paid" as active status turn "active" to false?

    allExpenses = [
      ExpenseItem(
        name: 'Uber Ride',
        price: '\$427.28',
        date: '2025-05-09T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$150.00'),
          GroupMember(name: '@abc123', status: 'Needs Approval', amount: '\$100.00'),
          GroupMember(name: '@xyz987', status: 'Approved', amount: '\$90.00'),
          GroupMember(name: '@pqr456', status: 'Needs Payment', amount: '\$87.28'),
        ],
      ),
      ExpenseItem(
        name: 'Dinner at Sushi Train',
        price: '\$78.38',
        date: '2024-12-26T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$28.38'),
          GroupMember(name: '@mno789', status: 'Needs Payment', amount: '\$50.00'),
        ],
      ),
      ExpenseItem(
        name: 'Movie Tickets',
        price: '\$373.11',
        date: '2025-01-04T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$123.11'),
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$100.00'),
          GroupMember(name: '@abc123', status: 'Approved', amount: '\$100.00'),
          GroupMember(name: '@pqr456', status: 'Needs Approval', amount: '\$50.00'),
        ],
      ),
      ExpenseItem(
        name: 'Taxi Split',
        price: '\$210.00',
        date: '2025-04-01T00:00:00',
        active: false,
        members: [
          GroupMember(name: 'You', amount: '\$70.00'),
          GroupMember(name: '@abc123', status: 'Paid', amount: '\$70.00'),
          GroupMember(name: '@xyz987', status: 'Paid', amount: '\$70.00'),
        ],
      ),
      ExpenseItem(
        name: 'Team Coffee',
        price: '\$95.00',
        date: '2025-02-12T00:00:00',
        active: false,
        members: [
          GroupMember(name: '@mno789', status: 'Paid', amount: '\$65.00'),
          GroupMember(name: '@pqr456', status: 'Paid', amount: '\$30.00'),
        ],
      ),
      ExpenseItem(
        name: 'Board Game Night',
        price: '\$120.00',
        date: '2025-03-15T00:00:00',
        active: false,
        members: [
          GroupMember(name: '@abc123', status: 'Paid', amount: '\$60.00'),
          GroupMember(name: 'You', amount: '\$60.00'),
        ],
      ),
      ExpenseItem(
        name: 'Flight Booking',
        price: '\$393.95',
        date: '2024-11-30T00:00:00',
        active: true,
        members: [
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$100.00'),
          GroupMember(name: 'You', amount: '\$143.95'),
          GroupMember(name: '@mno789', status: 'Needs Approval', amount: '\$150.00'),
        ],
      ),
      ExpenseItem(
        name: 'Haircut Subscription',
        price: '\$100.00',
        date: '2025-04-26T00:00:00',
        active: true,
        members: [
          GroupMember(name: 'You', amount: '\$50.00'),
          GroupMember(name: '@xyz987', status: 'Needs Payment', amount: '\$50.00'),
        ],
      ),
    ];
  }

  Future<void> _initialiseData() async {
    await _fetchGroupMembers();
    final fetchedGroup = await _fetchGroupNameandDescription();
    if (fetchedGroup != null) {
      setState(() {
        group = fetchedGroup;
        _descriptionController.text = group.description;
      });
    }
  }

  Future<Group> _fetchGroupNameandDescription() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      _logger.info(widget.groupUUID);
      final userReads = await apiService.groupApi.getGroup(widget.groupUUID);
      final group = Group(
        groupId: userReads!.groupId,
        name: userReads.name,
        description: userReads.description,
      );
      return group;
      
    } on ApiException catch (e) {
      _logger.info("API exception while fetching group members: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load group members",
      );
      return Group(
        groupId: "loading...",
        name: "loading...",
        description: "loading...",
      );
    } catch (e) {
      _logger.info("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
      return Group(
        groupId: "loading...",
        name: "loading...",
        description: "loading...",
      );
    }
  }

  Future<void> _fetchGroupMembers() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      _logger.info(widget.groupUUID);
      final userReads = await apiService.groupApi.getGroupUsers(widget.groupUUID);

      final fetchedMembers = userReads
          .map((user) => '@${user.nickname}')
          .toList();

      setState(() {
        groupMembers = fetchedMembers;
      });

      if (fetchedMembers.isEmpty) {
        _logger.info("Group has no members");
      }
    } on ApiException catch (e) {
      _logger.info("API exception while fetching group members: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load group members",
      );
    } catch (e) {
      _logger.info("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
    }
  }


  void handleSegmentChange(String newSegment) {
    setState(() {
      selectedSegment = newSegment;
    });
  }

  void handleTimePeriodChange(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        selectedPeriod = newPeriod;
      });
    }
  }

  List<ExpenseItem> getFilteredExpenses() {
    List<ExpenseItem> result = allExpenses;

    // Time filtering
    if (selectedPeriod != 'From Start') {
      final match = RegExp(r'Last (\d+) Days').firstMatch(selectedPeriod);
      if (match != null) {
        final int days = int.parse(match.group(1)!);
        final DateTime cutoff = DateTime.now().subtract(Duration(days: days));
        result = result.where((e) {
          try {
            return DateTime.parse(e.date).isAfter(cutoff);
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }

    // Segment filtering
    if (selectedSegment == 'Active') {
      result = result.where((e) => e.active).toList();
    }

    return result;
  }

  Future<void> _saveGroupDescription() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final updatedGroup = await apiService.groupApi.updateGroup(
        group.groupId,
        GroupCreate(name: group.name, description: _descriptionController.text),
      );

      setState(() {
        group = Group(
          groupId: updatedGroup.groupId,
          name: updatedGroup.name,
          description: updatedGroup.description,
        );
        isEditingDescription = false;
      });

      showCustomSnackBar(context, normalText: "Group description updated.");
    } on ApiException catch (e) {
      showCustomSnackBar(context, normalText: "Failed to update description.");
      Logger("GroupScreen").warning("Failed to update group: ${e.message}");
    }
  }


  Widget buildGroupMembersSection() {
    // if (groupMembers == null) {
    //   return const CircularProgressIndicator();
    // }
    // if (groupMembers!.isEmpty) {
    //   return const Text('No group members.');
    // }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Members',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: groupMembers.map((member) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
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
            vertical: proportionalSizes.scaleHeight(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildGroupMembersSection(),
              Text(
                "Description",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              isEditingDescription
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: null,
              decoration: const InputDecoration.collapsed(
                hintText: 'Edit group description...',
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isEditingDescription = false;
                    _descriptionController.text = group.description;
                  });
                },
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveGroupDescription,
                child: const Text("Save"),
              ),
            ],
          ),
        ],
      )
    : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              group.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  isEditingDescription = true;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
              ),
              child: const Text("Edit"),
            ),
          ),
        ],
      ),
              // isEditingDescription
              //   ? Column(
              //       children: [
              //         TextField(
              //           controller: _descriptionController,
              //           maxLines: null,
              //           decoration: InputDecoration(
              //             border: OutlineInputBorder(),
              //             labelText: 'Edit Description',
              //           ),
              //         ),
              //         const SizedBox(height: 8),
              //         ElevatedButton(
              //           onPressed: _saveGroupDescription,
              //           child: const Text("Save"),
              //         ),
              //       ],
              //     )
              //   : Column(
              //       children: [
              //         Text(
              //           group.description,
              //           style: const TextStyle(fontSize: 14, color: Colors.black87),
              //           textAlign: TextAlign.center,
              //         ),
              //         const SizedBox(height: 4),
              //         TextButton(
              //           onPressed: () {
              //             setState(() {
              //               isEditingDescription = true;
              //             });
              //           },
              //           child: const Text("Edit"),
              //         ),
              //       ],
              //     ),


              // Text(
              //   group.description,
              //   style: const TextStyle(fontSize: 14, color: Colors.black87),
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 20),
              

              ExpensesScreenSegmentControl(
                selectedSegment: selectedSegment,
                onSegmentChanged: handleSegmentChange,
              ),

              // Time Period Dropdown
              Align(
                alignment: Alignment.centerRight,
                child: TimePeriodDropdown(
                  selectedPeriod: selectedPeriod,
                  onChanged: handleTimePeriodChange,
                ),
              ),
              SizedBox(height: proportionalSizes.scaleHeight(20)),

              // Expense List
              IndGroupExpenseScreenList(expenses: getFilteredExpenses()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}