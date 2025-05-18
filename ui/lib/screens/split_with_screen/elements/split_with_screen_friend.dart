import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;

class SplitWithScreenFriend extends StatefulWidget {
  const SplitWithScreenFriend({super.key});

  @override
  State<SplitWithScreenFriend> createState() => _SplitWithScreenFriendState();
}

class _SplitWithScreenFriendState extends State<SplitWithScreenFriend> {
  List<String> allFriends = ['Alice', 'Bob', 'Charlie', 'David'];
  List<String> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    filteredFriends = List.from(allFriends);
  }

  void _filterFriends(String query) {
    final results = allFriends.where((friend) {
      return friend.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFriends = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            search.SearchBar(
              hintText: 'Search friends',
              onChanged: _filterFriends,
            ),
            const SizedBox(height: 20),

            // Filtered List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: proportionalSizes.scaleHeight(8),
                  ),
                  child: Text(
                    filteredFriends[index],
                    style: GoogleFonts.roboto(
                      fontSize: proportionalSizes.scaleHeight(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}