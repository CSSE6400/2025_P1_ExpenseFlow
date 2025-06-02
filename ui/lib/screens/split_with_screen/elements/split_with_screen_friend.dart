import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/color_palette.dart';
import 'package:flutter_frontend/common/custom_divider.dart';
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/icon_maker.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;

class Friend {
  String name;
  String percentage;
  bool checked;
  bool disabled;
  String userId;
  final TextEditingController controller;

  Friend({
    required this.name,
    required this.percentage,
    required this.checked,
    required this.disabled,
    required this.userId,
  }) : controller = TextEditingController(text: percentage);
}

class SplitWithScreenFriend extends StatefulWidget {
  final void Function(bool isValid)? onValidityChanged;
  final String? transactionId;
  final bool isReadOnly;

  const SplitWithScreenFriend({
    super.key,
    this.transactionId,
    this.isReadOnly = false,
    this.onValidityChanged,
  });

  @override
  State<SplitWithScreenFriend> createState() => SplitWithScreenFriendState();
}

class SplitWithScreenFriendState extends State<SplitWithScreenFriend> {
  late Friend you = Friend( name: 'Loading', userId: '1', percentage: '100', checked: true, disabled: false);
  List<Friend> otherFriends = [];
  List<Friend> filteredFriends = [];
  final Logger _logger = Logger("SplitWithFriendScreen");

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchFriends();
    filteredFriends = List.from(otherFriends);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onValidityChanged?.call(isTotalPercentageValid());
    });
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
            you = Friend(
            name: 'You',
            userId: fetchedUser.userId,
            percentage: '100',
            checked: true,
            disabled: false,
            );
      });
    }
  }

  Future<void> _fetchFriends() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final userReads = await apiService.friendApi.getFriends();

      setState(() {
        otherFriends = userReads
            .map((user) => Friend(
                  name: '@${user.nickname}',
                  userId: user.userId,
                  percentage: '',
                  checked: false,
                  disabled: false,
                ))
            .toList();
      });

      setState(() {
        filteredFriends = List.from(otherFriends);
      });
    } on ApiException catch (e) {
      _logger.warning("API exception while fetching friends: ${e.message}");
      showCustomSnackBar(
        context,
        normalText: "Failed to load friends",
      );
    } catch (e) {
      _logger.severe("Unexpected error: $e");
      showCustomSnackBar(
        context,
        normalText: "Something went wrong",
      );
    }
  }

  // based on search query
  void _filterFriends(String query) {
    final results = otherFriends.where((friend) {
      return friend.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFriends = results;
    });
  }

  void _toggleFriendSelection(Friend friend) {
    if (widget.isReadOnly || friend.disabled || friend.name == 'You') return;

    setState(() {
      friend.checked = !friend.checked;

      // default percentage
      if (friend.checked && friend.percentage.isEmpty) {
        friend.percentage = '0';
        friend.controller.text = '0';
      }

      if (!friend.checked) {
        friend.controller.text = '';
        friend.percentage = '';
      }
      
      filteredFriends.sort((a, b) {
        if (a.checked == b.checked) return 0;
        return a.checked ? -1 : 1;
      });
    });
  }

  bool isTotalPercentageValid() {
    final selected = [you, ...otherFriends.where((f) => f.checked)];
    final total = selected.fold<double>(
      0,
      (sum, f) => sum + (double.tryParse(f.percentage) ?? 0),
    );
    return total == 100;
  }

  void saveAndExit(BuildContext context) {
    // TODO: Save the data in the backend
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            search.SearchBar(
              hintText: 'Search friends',
              onChanged: _filterFriends,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Username', 
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: textColor,
                  )
                ),
                Text(
                  'Percentage', 
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: proportionalSizes.scaleHeight(18),
                    color: textColor,
                  )
                ),
              ],
            ),
            CustomDivider(),

            // You at the top
            _buildFriendRow(context, you, proportionalSizes, isYou: true),

            // Other friends
            ...filteredFriends.map((friend) {
              return _buildFriendRow(context, friend, proportionalSizes);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendRow(
    BuildContext context,
    Friend friend,
    ProportionalSizes proportionalSizes, {
    bool isYou = false,
  }) {
    final textColor = ColorPalette.primaryText;
    final unselectedTextColor = ColorPalette.secondaryText;

    return GestureDetector(
      onTap: () => _toggleFriendSelection(friend),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: proportionalSizes.scaleHeight(6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Username
            Text(
              friend.name,
              style: GoogleFonts.roboto(
                color: isYou
                    ? textColor
                    : friend.disabled
                        ? unselectedTextColor
                        : (friend.checked ? textColor : unselectedTextColor),
                fontSize: proportionalSizes.scaleHeight(18),
              ),
            ),

            // Checkmark + Editable % field
            Row(
              children: [
                if (friend.checked)
                  Padding(
                    padding: EdgeInsets.only(right: proportionalSizes.scaleWidth(6)),
                    child: IconMaker(
                      assetPath: 'assets/icons/check_nofilled.png',
                    ),
                  ),
                Container(
                  width: proportionalSizes.scaleWidth(70),
                  padding: EdgeInsets.symmetric(
                    horizontal: proportionalSizes.scaleWidth(8),
                    vertical: proportionalSizes.scaleHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: friend.checked ? unselectedTextColor.withValues(alpha: 0.5) : textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      proportionalSizes.scaleWidth(6),
                    ),
                  ),
                  child: TextField(
                    controller: friend.controller,
                    enabled: !widget.isReadOnly && friend.checked && !friend.disabled,
                    keyboardType: TextInputType.number,
                    onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          setState(() {
                            friend.percentage = value;
                            widget.onValidityChanged?.call(isTotalPercentageValid());
                          });
                        },
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: friend.checked ? textColor : unselectedTextColor,
                      fontSize: proportionalSizes.scaleHeight(14),
                    ),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      suffixText: '%',
                      suffixStyle: TextStyle(color: Color(0xFF0F2F63)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}