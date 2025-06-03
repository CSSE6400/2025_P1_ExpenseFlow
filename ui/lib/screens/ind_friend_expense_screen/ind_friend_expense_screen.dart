import 'package:flutter/material.dart';
import 'package:flutter_frontend/common/snack_bar.dart' show showCustomSnackBar;
import 'package:flutter_frontend/models/expense.dart';
import 'package:flutter_frontend/models/user.dart' show UserRead;
import 'package:flutter_frontend/services/api_service.dart' show ApiService;
import 'package:provider/provider.dart' show Provider;
// Common imports
import '../../common/color_palette.dart';
import '../../common/app_bar.dart';
import '../../common/bottom_nav_bar.dart';
import '../ind_friend_expense_screen/elements/ind_friend_expense_screen_main_body.dart';

class IndFriendExpenseScreen extends StatefulWidget {
  final String userId;

  const IndFriendExpenseScreen({super.key, required this.userId});

  @override
  State<IndFriendExpenseScreen> createState() => _IndFriendExpenseScreenState();
}

class _IndFriendExpenseScreenState extends State<IndFriendExpenseScreen> {
  UserRead? friend;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final fetchedUser = await apiService.friendApi.getFriend(widget.userId);
      if (fetchedUser == null) {
        if (!mounted) return;
        showCustomSnackBar(context, normalText: 'Friend not found');
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        friend = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(context, normalText: 'Failed to load fetch friend');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorPalette.background;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarWidget(screenName: "View Friend", showBackButton: true),

      body: IndFriendExpenseScreenMainBody(user: friend!),

      bottomNavigationBar: BottomNavBar(
        currentScreen: 'Individual Friend',
        inactive: false,
      ),
    );
  }
}
