import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class Constants {
  static const String merchantCode = "770000017893";
  static const String secureKey = "0c96f509-d488-4a6b-b08a-a0d9782a6517";
  static const String baseUrl = "https://atfawry.fawrystaging.com";
}

class FawryService {
  static LaunchMerchantModel getMerchantModel() {
    return LaunchMerchantModel(
      merchantCode: Constants.merchantCode,
      merchantRefNum: FawryUtils.randomAlphaNumeric(10),
      secureKey: Constants.secureKey,
    );
  }

  Future<void> startPayment(FawryLaunchModel model) async {
    try {
      await FawrySDK.instance.startPayment(
        launchModel: model,
        baseURL: Constants.baseUrl,
        lang: FawrySDK.LANGUAGE_ENGLISH,
      );
    } catch (e) {
      debugPrint('Error starting payment: $e');
    }
  }

  Future<void> openCardsManager(FawryLaunchModel model) async {
    try {
      await FawrySDK.instance.openCardsManager(
        launchModel: model,
        baseURL: Constants.baseUrl,
        lang: FawrySDK.LANGUAGE_ENGLISH,
      );
    } catch (e) {
      debugPrint('Error opening cards manager: $e');
    }
  }
}

BillItem item = BillItem(
  itemId: 'ITEM_ID',
  description: '',
  quantity: 5,
  price: 50,
);

List<BillItem> chargeItems = [item];

LaunchCustomerModel customerModel = LaunchCustomerModel(
  customerProfileId: '533518',
  customerName: 'John Doe',
  customerEmail: 'john.doe@xyz.com',
  customerMobile: '+201000000000',
);

FawryLaunchModel model = FawryLaunchModel(
  allow3DPayment: true,
  chargeItems: chargeItems,
  launchCustomerModel: customerModel,
  launchMerchantModel: FawryService.getMerchantModel(),
  skipLogin: true,
  skipReceipt: false,
  payWithCardToken: false,
  paymentMethods: PaymentMethods.ALL,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription? _fawryCallbackResultStream;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

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
          handleResponse(response);
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

  // Get the current platform
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

  // Initialize Fawry SDK with required parameters
  Future<void> startPayment() async {
    model.launchMerchantModel.merchantRefNum =
        FawryUtils.randomAlphaNumeric(10);
    await FawryService().startPayment(model);
  }

  Future<void> openCardsManager() async {
    model.launchMerchantModel.merchantRefNum =
        FawryUtils.randomAlphaNumeric(10);
    await FawryService().openCardsManager(model);
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Fawry SDK Flutter example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Text(currentPlatform()),
          ),
          Flexible(
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await startPayment();
                  },
                  child: const Text('Checkout / Pay'),
                ),
                const SizedBox(height: 5.0),
                ElevatedButton(
                  onPressed: () async {
                    await openCardsManager();
                  },
                  child: const Text('Manage Cards'),
                ),
                const SizedBox(height: 5.0),
                ElevatedButton(
                  onPressed: () async {
                    await _goToTheLake();
                  },
                  child: const Text('Open Google Maps To Lake'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
