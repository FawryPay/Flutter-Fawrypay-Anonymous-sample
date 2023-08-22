import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:fawry_sdk/fawry_sdk.dart';
import 'package:fawry_sdk/fawry_utils.dart';
import 'package:fawry_sdk/model/bill_item.dart';
import 'package:fawry_sdk/model/fawry_launch_model.dart';
import 'package:fawry_sdk/model/launch_customer_model.dart';
import 'package:fawry_sdk/model/launch_merchant_model.dart';
import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:fawry_sdk/model/response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fawry SDK Flutter',
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Future<void> initSDKCallback() async {
    try {
      _fawryCallbackResultStream =
          FawrySdk.instance.callbackResultStream().listen((event) {
        setState(() {
          ResponseStatus response = ResponseStatus.fromJson(jsonDecode(event));
          handleResponse(response);
        });
      });
    } catch (ex) {
      debugPrint(ex.toString());
    }
  }

  void handleResponse(ResponseStatus response) {
    switch (response.status) {
      case FawrySdk.RESPONSE_SUCCESS:
        {
          debugPrint('Message: ${response.message}');
          debugPrint('Json Response: ${response.data}');
        }
        break;
      case FawrySdk.RESPONSE_ERROR:
        {
          debugPrint('Error: ${response.message}');
        }
        break;
      case FawrySdk.RESPONSE_PAYMENT_COMPLETED:
        {
          debugPrint(
              'Payment Completed: ${response.message}, ${response.data}');
        }
        break;
    }
  }

  String currentPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Current platform --> Android';
      case TargetPlatform.iOS:
        return 'Current platform --> iOS';
      default:
        return 'Current platform --> Unknown';
    }
  }

  Future<void> initiateSDK() async {
    final item =
        BillItem(itemId: 'Item1', description: 'Book', quantity: 6, price: 50);
    final chargeItems = [item];

    final customerModel = LaunchCustomerModel(
      customerProfileId: '533518',
      customerName: 'John Doe',
      customerEmail: 'john.doe@xyz.com',
      customerMobile: '+201000000000',
    );

    final merchantModel = LaunchMerchantModel(
      merchantCode: "+/IAAY2notgLsdUB9VeTFg==",
      merchantRefNum: FawryUtils.randomAlphaNumeric(10),
      secureKey: '69826c87-963d-47b7-8beb-869f7461fd93',
    );

    final model = FawryLaunchModel(
      allow3DPayment: true,
      chargeItems: chargeItems,
      launchCustomerModel: customerModel,
      launchMerchantModel: merchantModel,
      skipLogin: true,
      skipReceipt: true,
      payWithCardToken: false,
      paymentMethods: PaymentMethods.ALL,
    );

    await FawrySdk.instance.init(
      launchModel: model,
      baseURL: "https://atfawry.fawrystaging.com/",
      lang: FawrySdk.LANGUAGE_ENGLISH,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Fawry SDK Flutter example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Text(currentPlatform()),
          ),
          ElevatedButton(
            onPressed: () async {
              await initiateSDK();
            },
            child: const Text('Checkout / Pay'),
          ),
        ],
      ),
    );
  }
}
