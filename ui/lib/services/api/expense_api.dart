import 'dart:convert';

import 'package:flutter_frontend/models/expense.dart'
    show ExpenseCreate, ExpenseRead;
import 'package:flutter_frontend/services/api/common.dart';
import 'package:flutter_frontend/services/api_service.dart' show ApiException;

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
}
