import 'dart:async';
import 'dart:convert';
import 'package:fawry_sdk/fawry_sdk.dart';
import 'package:fawry_sdk/model/bill_item.dart';
import 'package:fawry_sdk/model/fawry_launch_model.dart';
import 'package:fawry_sdk/model/launch_apple_pay_model.dart';
import 'package:fawry_sdk/model/launch_checkout_model.dart';
import 'package:fawry_sdk/model/launch_customer_model.dart';
import 'package:fawry_sdk/model/launch_merchant_model.dart';
import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:fawry_sdk/model/response.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

// import your SDK
// import 'package:fawry_sdk/fawry_sdk.dart';

final _uuid = const Uuid();

/// =======================================================
/// CONSTANTS
/// =======================================================

final List<BillItem> cartItems = [
  BillItem(
    itemId: 'EGMHOC23DP11',
    quantity: 1,
    price: 1000,
    description: 'Item 1 Description',
  ),
];

LaunchMerchantModel get merchant => LaunchMerchantModel(
  merchantCode: Constants.merchantCode,
  merchantRefNum: _uuid.v4(),
  //if you need to use signature you don't need to pass secureKey
  secureKey: Constants.merchantSecretCode,
);


LaunchCustomerModel get customer => LaunchCustomerModel(
  customerName: 'Ahmed Kamal',
  customerMobile: '+1234567890',
  customerEmail: 'ahmed.kamal@example.com',
  customerProfileId: '280926',
);

LaunchApplePayModel getApplePayModel() {
  return LaunchApplePayModel(merchantID: "merchant.NUMUMARKET");
}

LaunchCheckoutModel getCheckoutModel() {
  return LaunchCheckoutModel(
    scheme: "myfawry",
  );
}

/// =======================================================
/// SIGNATURE GENERATION
/// =======================================================
String generateFawrySignature({
  required String merchantCode,
  required String merchantRefNum,
  required String customerProfileId,
  required List<BillItem> items,
  bool isPaymentSignature = true,
}) {
  final validItems = items.where((item) =>
  item.itemId.isNotEmpty &&
      item.quantity != 0 &&
      item.price != 0).toList();

  if (validItems.isEmpty) {
    throw Exception('No valid items found for signature generation');
  }

  // Sort by itemId
  validItems.sort((a, b) => a.itemId.compareTo(b.itemId));

  String formatPrice(String value) {
    final parsed = double.tryParse(value) ?? 0;
    return parsed.toStringAsFixed(2);
  }

  final itemsString = validItems.map((item) {
    return '${item.itemId}${item.quantity}${formatPrice(item.price?.toString() ?? "0")}';
  }).join();

  final signatureString =
      merchantCode +
          (isPaymentSignature ? merchantRefNum : '') +
          customerProfileId +
          (isPaymentSignature ? itemsString : '') +
          Constants.merchantSecretCode;

  if (isPaymentSignature) {
    debugPrint('[FAWRY][Flutter] *********** paymentSignature ***********');
  } else {
    debugPrint('[FAWRY][Flutter] *********** tokenizationSignature ***********');
  }

  debugPrint('[FAWRY][Flutter] merchantCode: $merchantCode');
  if (isPaymentSignature) {
    debugPrint('[FAWRY][Flutter] merchantRefNum: $merchantRefNum');
  }
  debugPrint('[FAWRY][Flutter] customerProfileId: $customerProfileId');
  if (isPaymentSignature) {
    debugPrint('[FAWRY][Flutter] itemsString: $itemsString');
  }
  debugPrint('[FAWRY][Flutter] secureHashKey: ${Constants.merchantSecretCode}');
  debugPrint('[FAWRY][Flutter] signatureString: $signatureString');

  final hash = sha256.convert(utf8.encode(signatureString)).toString();

  debugPrint('[FAWRY][Flutter] hashString: $hash');

  return hash;
}

/// =======================================================
/// BUILD LAUNCH MODEL
/// =======================================================
FawryLaunchModel buildLaunchModel() {
  var launchMerchantModel = merchant;

  final paymentSignature = generateFawrySignature(
    merchantCode: launchMerchantModel.merchantCode,
    merchantRefNum: launchMerchantModel.merchantRefNum,
    customerProfileId: customer.customerProfileId ?? "",
    items: cartItems,
    isPaymentSignature: true,
  );

  final tokenizationSignature = generateFawrySignature(
    merchantCode: launchMerchantModel.merchantCode,
    merchantRefNum: launchMerchantModel.merchantRefNum,
    customerProfileId: customer.customerProfileId ?? "",
    items: cartItems,
    isPaymentSignature: false,
  );

  return FawryLaunchModel(
    //paymentSignature: paymentSignature,
    //tokenizationSignature: tokenizationSignature,
    allow3DPayment: true,
    skipReceipt: false,
    skipLogin: true,
    payWithCardToken: true,
    chargeItems: cartItems,
    paymentMethods: PaymentMethods.ALL,
    launchMerchantModel: launchMerchantModel,
    launchCustomerModel: customer,
    launchApplePayModel: getApplePayModel(),
    launchCheckOutModel: getCheckoutModel(),
  );
}

/// =======================================================
/// START PAYMENT
/// =======================================================
Future<void> _startPayment() async {
  try {

    debugPrint("Starting payment with base URL: ${Constants.baseUrl}");
    FawrySDK.instance.startPayment(
      baseURL: Constants.baseUrl,
      lang: Constants.lang,
      launchModel: buildLaunchModel(),



    );
  } on PlatformException catch (e) {
    debugPrint("Failed to start payment: ${e.message}");
  }
}

/// =======================================================
/// MANAGE CARDS
/// =======================================================
Future<void> _manageCards() async {
  try {
    debugPrint("Starting manageCards with base URL: ${Constants.baseUrl}");
    FawrySDK.instance.manageCards(
      baseURL: Constants.baseUrl,
      lang: Constants.lang,
      launchModel: buildLaunchModel(),

    );
  } on PlatformException catch (e) {
    debugPrint("Failed to manage cards: ${e.message}");
  }
}

/// =======================================================
/// UI
/// =======================================================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late StreamSubscription? _fawryCallbackResultStream;

  @override
  void initState() {
    super.initState();
    initSDKCallback();
  }

  @override
  void dispose() {
    _fawryCallbackResultStream?.cancel();
    super.dispose();
  }

  // Initialize the Fawry SDK callback
  Future<void> initSDKCallback() async {
    try {
      _fawryCallbackResultStream =
          FawrySDK.instance.callbackResultStream().listen((event) {
            setState(() {
              ResponseStatus response = ResponseStatus.fromJson(jsonDecode(event));
              switch (response.status) {
                case FawrySDK.RESPONSE_SUCCESS:
                  {
                    //Success status
                    debugPrint('Message : ${response.message}');
                    //Success json response
                    debugPrint('Json Response : ${response.data}');
                  }
                  break;
                case FawrySDK.RESPONSE_ERROR:
                  {
                    debugPrint('Error : ${response.message}');
                  }
                  break;
                case FawrySDK.RESPONSE_PAYMENT_COMPLETED:
                  {
                    debugPrint(
                        'Payment Completed : ${response.message} , ${response.data}');
                  }
                  break;
              }
            });
          });
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  // Handle the response from Fawry SDK
  void handleResponse(ResponseStatus response) {
    switch (response.status) {
      case FawrySDK.RESPONSE_SUCCESS:
        {
          debugPrint('Message: ${response.message}');
          debugPrint('Json Response: ${response.data}');
        }
        break;
      case FawrySDK.RESPONSE_ERROR:
        {
          debugPrint('Error: ${response.message}');
        }
        break;
      case FawrySDK.RESPONSE_PAYMENT_COMPLETED:
        {
          debugPrint(
              'Payment Completed: ${response.message}, ${response.data}');
        }
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fawry Flutter Example')),
        body: const Padding(
          padding: const EdgeInsets.all(24),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ElevatedButton(
                onPressed: _startPayment,
                child: const Text('Start Payment'),
              ),
              const SizedBox(height: 16),
              const ElevatedButton(
                onPressed: _manageCards,
                child: const Text('Manage Cards'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Constants {
  static String lang = FawrySDK.LANGUAGE_ARABIC;
  static String merchantCode = '400000012230';
  static String merchantSecretCode = '69826c87-963d-47b7-8beb-869f7461fd93';
  static const String baseUrl = "https://atfawry.fawrystaging.com/";
}
