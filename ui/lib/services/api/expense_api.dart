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

  Future<List<ExpenseRead>> getExpensesUploadedByMe() async {
    final response = await client.get(backendUri("/expenses"));

    if (response.statusCode == 200) {
      // parse response body to List<ExpenseRead>
      return (jsonDecode(response.body) as List)
          .map((e) => ExpenseRead.fromJson(e))
          .toList();
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
