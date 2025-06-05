import 'package:flutter/material.dart';
import 'package:expenseflow/models/user.dart';

class GroupMembersSection extends StatelessWidget {
  final List<UserGroupRead> groupMembers;

  const GroupMembersSection({super.key, required this.groupMembers});

  @override
  Widget build(BuildContext context) {
    if (groupMembers.isEmpty) {
      return const Text('No group members.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Group Members',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                groupMembers.map((member) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      member.nickname,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
