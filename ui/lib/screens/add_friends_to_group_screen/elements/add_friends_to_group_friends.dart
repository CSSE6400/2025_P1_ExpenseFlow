import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/custom_divider.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;

class Friend {
  final String userId;
  final String name;
  bool isSelected;

  Friend({required this.userId, required this.name, this.isSelected = false});
}


class AddFriendsScreenItem extends StatefulWidget {
  final List<Friend> items;
  final bool isReadOnly;
  final Function(List<Friend> items, bool hasChanges) onItemsChanged;

  const AddFriendsScreenItem({
    super.key,
    required this.items,
    required this.onItemsChanged,
    this.isReadOnly = false,
  });

  @override
  State<AddFriendsScreenItem> createState() => _AddFriendsScreenItemState();
}

class _AddFriendsScreenItemState extends State<AddFriendsScreenItem> {
  List<Friend> allFriends = [];
  List<Friend> filteredFriends = [];
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    allFriends = List.from(widget.items);
    filteredFriends = List.from(allFriends);
  }

  @override
  void didUpdateWidget(covariant AddFriendsScreenItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        allFriends = List.from(widget.items);
        filteredFriends = List.from(allFriends);
      });
    }
  }


  void _toggleSelection(Friend friend, bool? selected) {
    setState(() {
      friend.isSelected = selected ?? false;
      hasChanges = true;
    });
    widget.onItemsChanged(allFriends, hasChanges);
  }

  void _filterFriends(String query) {
    setState(() {
      filteredFriends = allFriends.where((friend) {
        return friend.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _removeFriend(Friend friend) {
    setState(() {
      allFriends.remove(friend);
      filteredFriends = List.from(allFriends);
      hasChanges = true;
    });
    widget.onItemsChanged(allFriends, hasChanges);
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(hintText: 'Search friends', onChanged: _filterFriends),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: filteredFriends.map((friend) {
              return ListTile(
                leading: Checkbox(
                  value: friend.isSelected,
                  onChanged: widget.isReadOnly
                      ? null
                      : (selected) => _toggleSelection(friend, selected),
                ),
                title: Text(friend.name),
              );
            }).toList(),
          ),
        ),
        if (filteredFriends.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(proportionalSizes.scaleHeight(20)),
              child: Text('No friends found'),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
