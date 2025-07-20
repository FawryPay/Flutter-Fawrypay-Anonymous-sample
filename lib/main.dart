import 'dart:convert';
import 'dart:io';

import 'package:fawry_sdk/model/bill_item.dart';
import 'package:fawry_sdk/model/fawry_launch_model.dart';
import 'package:fawry_sdk/model/launch_apple_pay_model.dart';
import 'package:fawry_sdk/model/launch_checkout_model.dart';
import 'package:fawry_sdk/model/launch_customer_model.dart';
import 'package:fawry_sdk/model/launch_merchant_model.dart';
import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fawry_sdk/fawry_sdk.dart';
import 'package:fawry_sdk/model/response.dart';
import 'package:fawry_sdk/fawry_utils.dart';

class Constants {
  static String merchantCode = '+/IAAY2nothN6tNlekupwA==';

  static String secureKey = "4b815c12-891c-42ab-b8de-45bd6bd02c3d";

  static const String baseUrl = "https://atfawry.fawrystaging.com/";
}

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

  LaunchMerchantModel getMerchantModel() {
    return LaunchMerchantModel(
      merchantCode: Constants.merchantCode,
      merchantRefNum: FawryUtils.randomAlphaNumeric(10),
      secureKey: Constants.secureKey,
    );
  }

  LaunchApplePayModel getApplePayModel() {
    return LaunchApplePayModel(merchantID: "merchant.NUMUMARKET"

    );
  }

  LaunchCheckoutModel getCheckoutModel() {
    return LaunchCheckoutModel(
      scheme: "myfawry",
    );
  }

  FawryLaunchModel buildLaunchModel() {
    BillItem item1 = BillItem(
      itemId: 'item1',
      description: 'Item 1',
      quantity: 1,
      price: 300.00,
    );
    BillItem item2 = BillItem(
      itemId: 'item2',
      description: 'Item 2',
      quantity: 1,
      price: 200.00,
    );
    BillItem item3 = BillItem(
      itemId: 'item3',
      description: 'Item 3',
      quantity: 1,
      price: 500.00,
    );

    List<BillItem> chargeItems = [item1, item2, item3];
    LaunchCustomerModel customerModel = LaunchCustomerModel(
      customerName: 'Ahmed Kamal',
      customerMobile: '+1234567890',
      customerEmail: 'ahmed.kamal@example.com',
      customerProfileId: '12345',
      //customerProfileId: '280926',
    );

    return FawryLaunchModel(
      allow3DPayment: true,
      chargeItems: chargeItems,
      launchCustomerModel: customerModel,
      launchMerchantModel: LaunchMerchantModel(
        merchantCode: Constants.merchantCode,
        secureKey: Constants.secureKey,
        merchantRefNum: DateTime.now().millisecondsSinceEpoch.toString(), // to match Kotlin’s timestamp logic
      ),
      skipLogin: true,
      skipReceipt: false,
      payWithCardToken: true,
      paymentMethods: PaymentMethods.ALL,
      launchApplePayModel: getApplePayModel(),
      launchCheckOutModel: getCheckoutModel(),
    );
  }



  var paymentMethod =PaymentMethods.ALL;
  var language = FawrySDK.LANGUAGE_ARABIC;




  Future<void> _startPayment() async {
    try {

      debugPrint("Starting payment with base URL: ${Constants.baseUrl}");
      FawrySDK.instance.startPayment(
        baseURL: Constants.baseUrl,
        lang: language,
        launchModel: buildLaunchModel(),



      );
    } on PlatformException catch (e) {
      debugPrint("Failed to start payment: ${e.message}");
    }
  }

  Future<void> _manageCards() async {
    try {
      debugPrint("Starting manageCards with base URL: ${Constants.baseUrl}");
      FawrySDK.instance.manageCards(
        baseURL: Constants.baseUrl,
        lang: language,
        launchModel: buildLaunchModel(),

      );
    } on PlatformException catch (e) {
      debugPrint("Failed to manage cards: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fawry SDK Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startPayment,
                child: const Text("Start Payment"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _manageCards,
                child: const Text("Manage Cards"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}