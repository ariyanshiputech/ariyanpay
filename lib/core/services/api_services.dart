// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:ariyanpay/models/credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ariyanpay/controllers/payment_controller.dart';
import 'package:ariyanpay/models/customer_model.dart';
import 'package:ariyanpay/models/request_response.dart';
import 'package:ariyanpay/utils/config.dart';
import 'package:ariyanpay/utils/endpoints.dart';
import 'package:ariyanpay/widget/custom_snackbar.dart';

class ApiServices {
  static Future<Map<dynamic, dynamic>> createPaymentRequest({
    AriyanpayCredentials? ariyanpayCredentials,
    required CustomerDetails customer,
    required String amount,
    dynamic valueA,
    dynamic valueB,
    dynamic valueC,
    dynamic valueD,
    dynamic valueE,
    dynamic valueF,
    dynamic valueG,
    Map? metadata,
    String? webhookUrl,
    required BuildContext context,
  }) async {
    final Map<dynamic, dynamic> requestData = {
      'cus_name': customer.fullName,
      'cus_phone': customer.cusPhone,
      'invoice_id': 'PAY${DateTime.now().millisecondsSinceEpoch}',
      'amount': amount,
      'value_a': valueA,
      'value_b': valueB,
      'value_c': valueC,
      'value_d': valueD,
      'value_e': valueE,
      'value_f': valueF,
      'value_g': valueG,
      'success_url': AppConfig.redirectURL,
      'cancel_url': AppConfig.cancelURL,
      'type': 'GET',
    };

    final controller = Get.put(PaymentController());

    if (ariyanpayCredentials == null) {
      controller.panelURL.value = AppConfig.sandboxURL;
      controller.apiKey.value = AppConfig.sandboxAPIKey;
    } else {
      controller.panelURL.value = ariyanpayCredentials.panelURL;
      controller.apiKey.value = ariyanpayCredentials.apiKey;
    }

    try {
      final http.Response response = await http.post(
        Uri.parse(
          ariyanpayCredentials == null
              ? AppConfig.sandboxURL + Endpoints.createPayment
              : '${ariyanpayCredentials.panelURL}${Endpoints.createPayment}',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        return {
          'status': responseData['status'],
          'message': responseData['message'],
          'payment_url': responseData['payment_url'],
        };
      } else {
        final error = jsonDecode(response.body)['message'];
        snackBar(error, context);
        debugPrint(error);
        throw Exception(error);
      }
    } catch (error) {
      snackBar('Something is wrong', context);
      throw Exception('Something is wrong');
    }
  }

  static Future<RequestResponse> verifyPayment(
    String invoiceId,
    BuildContext context,
  ) async {
    final Map<String, dynamic> requestData = {
      'invoice_id': invoiceId,
    };

    final controller = Get.put(PaymentController());

    final http.Response response = await http.post(
      Uri.parse(
        '${controller.panelURL.value}${Endpoints.verifyPayment}',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      return requestResponseFromJson(response.body);
    } else {
      final decoded = jsonDecode(response.body);
      snackBar(decoded['message'], context);
      throw Exception(decoded['message']);
    }
  }
}
