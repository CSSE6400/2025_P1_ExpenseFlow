import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/color_palette.dart';
import '../../../common/proportional_sizes.dart';
import '../../../common/search_bar.dart' as search;
import '../../../common/custom_button.dart';
import '../../../common/dialogs/app_dialog_box.dart';
import 'package:flutter_frontend/services/api_service.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:flutter_frontend/common/snack_bar.dart';
import 'package:logging/logging.dart';

class FriendRequest {
  final String name;
  final bool isIncoming;

  FriendRequest({required this.name, required this.isIncoming});
}

class ManageFriendsRequests extends StatefulWidget {
  const ManageFriendsRequests({super.key});

  @override
  State<ManageFriendsRequests> createState() => _ManageFriendsRequestsState();
}

class _ManageFriendsRequestsState extends State<ManageFriendsRequests> {
  List<FriendRequest> allRequests = [];
  List<FriendRequest> filteredRequests = [];
  final Logger _logger = Logger("ManageFriendsREquestsLogger");

  @override
  void initState() {
    super.initState();
    _fetchRequests();

    // TODO: Load friend requests from backend
    // Incoming means the user has received a request,
    // Outgoing means the user has sent a request
    // allRequests = [
    //   FriendRequest(name: '@abc123', isIncoming: true),
    //   FriendRequest(name: '@xyz987', isIncoming: false),
    //   FriendRequest(name: '@pqr456', isIncoming: true),
    //   FriendRequest(name: '@def321', isIncoming: false),
    //   FriendRequest(name: '@mno789', isIncoming: true),
    //   FriendRequest(name: '@uvw654', isIncoming: false),
    //   FriendRequest(name: '@lmn123', isIncoming: true),
    //   FriendRequest(name: '@opq456', isIncoming: false),
    // ];

    // filteredRequests = _sorted(List.from(allRequests));
  }

  Future<void> _fetchRequests() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
            final userReadsSent = await apiService.friendApi.getSentFriendRequests();
      final userReadsIncoming =
          await apiService.friendApi.getReceivedFriendRequests();

      final sentRequests = userReadsSent
          .map((user) => FriendRequest(
                name: '@${user.firstName}',
                isIncoming: false,
              ))
          .toList();

      final incomingRequests = userReadsIncoming
          .map((user) => FriendRequest(
                name: '@${user.firstName}',
                isIncoming: true,
              ))
          .toList();

      setState(() {
        allRequests = [...incomingRequests, ...sentRequests];
        filteredRequests = _sorted(List.from(allRequests));
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

  List<FriendRequest> _sorted(List<FriendRequest> list) {
    // Incoming requests first, then outgoing
    list.sort((a, b) {
      if (a.isIncoming == b.isIncoming) return 0;
      return a.isIncoming ? -1 : 1;
    });
    return list;
  }

  void _filterRequests(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRequests = _sorted(List.from(allRequests));
      } else {
        filteredRequests = _sorted(
          allRequests
              .where((user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()))
              .toList(),
        );
      }
    });
  }

  void _onAcceptRequest(BuildContext context, String username) async {
    await AppDialogBox.show(
      context,
      heading: 'Accept Friend Request',
      description: 'Do you want to accept the friend request from $username?',
      buttonCount: 2,
      button2Text: 'Yes',
      onButton2Pressed: () {
        setState(() {
          allRequests.removeWhere(
              (r) => r.name == username && r.isIncoming);
          filteredRequests.removeWhere(
              (r) => r.name == username && r.isIncoming);
        });
        Navigator.of(context).pop();
        // TODO: Call backend to accept the friend request
      },
      button1Text: 'Cancel',
      button1Color: ColorPalette.error,
      onButton1Pressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proportionalSizes = ProportionalSizes(context: context);
    final textColor = ColorPalette.primaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.SearchBar(
          hintText: 'Search by username',
          onChanged: _filterRequests,
        ),
        const SizedBox(height: 16),

        if (filteredRequests.isEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: proportionalSizes.scaleHeight(20),
            ),
            child: Center(
              child: Text(
                'No requests found',
                style: GoogleFonts.roboto(
                  fontSize: proportionalSizes.scaleText(16),
                  color: ColorPalette.secondaryText,
                ),
              ),
            ),
          )
        else
          ...filteredRequests.map((request) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: proportionalSizes.scaleHeight(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Username
                    Expanded(
                      child: Text(
                        request.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: proportionalSizes.scaleText(18),
                          color: textColor,
                        ),
                      ),
                    ),
                    // Button
                    request.isIncoming
                        ? CustomButton(
                            label: 'Accept',
                            onPressed: () =>
                                _onAcceptRequest(context, request.name),
                            sizeType: ButtonSizeType.quarter,
                          )
                        : CustomButton(
                            label: 'Sent',
                            onPressed: () {},
                            state: ButtonState.disabled,
                            sizeType: ButtonSizeType.quarter,
                          ),
                  ],
                ),
              )),
      ],
    );
  }
}