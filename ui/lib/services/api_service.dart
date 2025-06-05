import 'package:expenseflow/services/api/expense_api.dart';
import 'package:expenseflow/services/api/friend_api.dart';
import 'package:expenseflow/services/api/group_api.dart';
import 'package:expenseflow/services/api/user_api.dart';
import 'package:expenseflow/services/auth_service.dart'
    show AuthenticatedClient;
import 'package:logging/logging.dart' show Logger;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;

  ApiException(this.statusCode, this.message, [this.responseBody]);

  @override
  String toString() {
    return 'ApiException: [$statusCode] $message'
        '${responseBody != null ? '\nResponse Body: $responseBody' : ''}';
  }
}

class ApiService {
  final AuthenticatedClient client;
  final String baseUrl;
  final Logger logger = Logger("ApiService");

  // Api Clients
  late final UserApiClient _userApi;
  late final ExpenseApiClient _expenseApi;
  late final FriendApiClient _friendApi;
  late final GroupApiClient _groupApi;

  ApiService(this.client, this.baseUrl) {
    _userApi = UserApiClient(client, baseUrl, logger);
    _expenseApi = ExpenseApiClient(client, baseUrl, logger);
    _friendApi = FriendApiClient(client, baseUrl, logger);
    _groupApi = GroupApiClient(client, baseUrl, logger);
  }

  UserApiClient get userApi => _userApi;
  ExpenseApiClient get expenseApi => _expenseApi;
  FriendApiClient get friendApi => _friendApi;
  GroupApiClient get groupApi => _groupApi;
}
