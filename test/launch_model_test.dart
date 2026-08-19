import 'dart:convert';

import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:flutter_fawry_sdk/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launch model excludes wallet as an example payment method', () {
    final model = buildLaunchModel();
    final json = model.toJson();

    expect(model.excludePaymentMethods, [PaymentMethods.WALLET]);
    expect(json['excludePaymentMethods'], ['WALLET']);
    expect(json.containsKey('paymentMethods'), isFalse);
    expect(json.containsKey('paymentMethod'), isFalse);
    expect(() => jsonEncode(json), returnsNormally);
  });
}
