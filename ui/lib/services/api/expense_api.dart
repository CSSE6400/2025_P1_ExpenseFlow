import 'dart:convert';

import 'package:flutter_frontend/common/scan_receipt.dart' show WebImageInfo;
import 'package:flutter_frontend/models/enums.dart'
    show ExpenseStatus, ExpenseStatusConverter;
import 'package:flutter_frontend/models/expense.dart'
    show ExpenseCreate, ExpenseOverview, ExpenseRead, SplitStatusInfo;
import 'package:flutter_frontend/services/api/common.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiException;
import 'package:http/http.dart' as http;

class ExpenseApiClient extends BaseApiClient {
  ExpenseApiClient(super.client, super.baseUrl, super.logger);

  Future<ExpenseRead> createExpense(ExpenseCreate body) async {
    final response = await client.post(
      backendUri("/expenses"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // parse response body to ExpenseRead
      return ExpenseRead.fromJson(safeJsonDecode((response.body)));
    } else {
      logger.info(
        "Failed to create expense: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create expense',
        response.body,
      );
    }
  }

  Future<ExpenseRead> updateExpense(
    String expenseId,
    ExpenseCreate body,
  ) async {
    final response = await client.put(
      backendUri("/expenses/$expenseId"),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return ExpenseRead.fromJson(safeJsonDecode((response.body)));
    } else {
      logger.info(
        "Failed to create expense: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create expense',
        response.body,
      );
    }
  }

  Future<ExpenseOverview> getOverview() async {
    final response = await client.get(backendUri("/expenses/overview"));

    if (response.statusCode == 200) {
      return ExpenseOverview.fromJson(safeJsonDecode((response.body)));
    } else {
      logger.info(
        "Failed to get expense overview: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to get expense overview',
        response.body,
      );
    }
  }

  Future<ExpenseRead?> getExpense(String expenseId) async {
    final response = await client.get(backendUri("/expenses/$expenseId"));

    if (response.statusCode == 200) {
      return ExpenseRead.fromJson(safeJsonDecode((response.body)));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      logger.info(
        "Failed to get expense: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to get expense',
        response.body,
      );
    }
  }

  Future<List<ExpenseRead>> getExpensesUploadedByMe() async {
    final response = await client.get(backendUri("/expenses"));

    if (response.statusCode == 200) {
      return safeJsonDecodeList(response.body, ExpenseRead.fromJson);
    } else {
      logger.info(
        "Failed to fetch expenses: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to fetch expenses',
        response.body,
      );
    }
  }

  Future<ExpenseStatus?> getMyExpenseStatus(String expenseId) async {
    final response = await client.get(
      backendUri("/expenses/$expenseId/my-status"),
    );

    if (response.statusCode == 200) {
      final statusString = safeJsonDecode(response.body);
      return ExpenseStatusConverter().fromJson(statusString);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      logger.info(
        "Failed to get expense status: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to get expense status',
        response.body,
      );
    }
  }

  Future<List<SplitStatusInfo>> getAllExpenseStatuses(String expenseId) async {
    // Get a list of the statuses for each user in an expense
    final response = await client.get(
      backendUri("/expenses/$expenseId/all-status"),
    );

    if (response.statusCode == 200) {
      return safeJsonDecodeList(response.body, SplitStatusInfo.fromJson);
    } else {
      logger.info(
        "Failed to get expense status for all users: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to get expense status for all users',
        response.body,
      );
    }
  }

  Future<ExpenseRead?> changeExpenseStatus(
    String expenseId,
    ExpenseStatus status,
  ) async {
    final response = await client.put(
      backendUri("/expenses/$expenseId/status?status=${status.label}"),
    );

    if (response.statusCode == 200) {
      return ExpenseRead.fromJson(safeJsonDecode((response.body)));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      logger.info(
        "Failed to get expense status: ${response.statusCode} ${response.body}",
      );
      throw ApiException(
        response.statusCode,
        'Failed to get expense status',
        response.body,
      );
    }
  }

  Future<ExpenseRead> createExpenseFromImage(
    WebImageInfo image,
    String? parentId,
  ) async {
    // NOTE: THIS HAS NOT BEEN TESTED
    final uri = backendUri("/expenses/auto");
    final request = http.MultipartRequest('POST', uri);

    // read bytes bytes from WebImageInfo abstraction
    final bytes = await image.getBytes();

    final multipartFile = http.MultipartFile.fromBytes(
      'file', // Must match FastAPI param name
      bytes,
      filename: image.filename,
    );

    request.files.add(multipartFile);

    // Optional form fields (like parent_id)
    if (parentId != null) {
      request.fields['parent_id'] = parentId;
    }

    final token = await client.authService.getAccessToken();
    if (token == null) {
      throw Exception('No access token found. Please log in.');
    }
    request.headers["Authorization"] = "Bearer $token";

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return ExpenseRead.fromJson(safeJsonDecode((respStr)));
    } else {
      logger.info(
        "Failed to create expense from image: ${response.statusCode} $respStr",
      );
      throw ApiException(
        response.statusCode,
        'Failed to create expense from image',
        respStr,
      );
    }
  }
}
