# Fawry SDK Integration Guide

Welcome to the comprehensive Fawry SDK Integration Guide. This guide will walk you through the seamless integration of Fawry's native Android and iOS SDKs into your Flutter projects for effortless payment integration.

## Table of Contents

1. [Getting Started](#getting-started)
   - [Adding Fawry SDK Plugin](#adding-fawry-sdk-plugin)
   - [Android Setup](#android-setup)
   - [iOS Setup](#ios-setup)
   - [Fawry SDK Imports](#fawry-sdk-imports)
   - [Streaming Result Data](#streaming-result-data)
2. [SDK Initialization](#sdk-initialization)
   - [Building FawryLaunchModel](#building-fawrylaunchmodel)
   - [Example](#example)
   - [Start Payment](#start-payment)
   - [Open Cards Manager](#open-cards-manager)
3. [Customizing UI Colors](#customizing-ui-colors)
   - [Android](#android)
   - [iOS](#ios)
4. [Troubleshooting Release Mode](#troubleshooting-release-mode)
5. [Sample Project](#sample-project)

---

## Getting Started

### Adding Fawry SDK Plugin

To begin, add the Fawry SDK plugin to your Flutter project's dependencies. Open your `pubspec.yaml` file and add the following line:

```yaml
dependencies:
  fawry_sdk: ^2.0.1
```

### Android Setup

To integrate with Android, follow these steps:

1. Open your `AndroidManifest.xml` file and insert the following code snippet inside the `<application>` tag:

```xml
<!-- Add this code inside the <application> tag -->
<application
    android:allowBackup="false"
    android:icon="@mipmap/ic_launcher"
    android:label="Your App Label"
    tools:replace="android:label">
    <!-- Remove 'android:label' from tools:replace if not defining a label -->
</application>
```

2. Update the **minimum SDK version** to **21** or higher in your `build.gradle` file:

```groovy
android {
    compileSdkVersion flutter.compileSdkVersion
    minSdkVersion 21
    // ...
}
```

**Notice:** Make sure to upgrade your Kotlin version to 1.9.0 to ensure compatibility with the Fawry SDK

### iOS Setup

For iOS integration, follow these steps:

1. Set the minimum iOS version under "Deployment info" to **12.1** or higher in your `Runner` project in Xcode.

2. Enhance pod distribution by adding the following code at the end of the pod file (`Podfile`):

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end
```

### Fawry SDK Imports

Before you proceed, make sure to import the necessary Fawry SDK packages at the beginning of your Dart file:

```dart
import 'package:fawry_sdk/fawry_sdk.dart';
import 'package:fawry_sdk/fawry_utils.dart';
import 'package:fawry_sdk/model/bill_item.dart';
import 'package:fawry_sdk/model/fawry_launch_model.dart';
import 'package:fawry_sdk/model/launch_customer_model.dart';
import 'package:fawry_sdk/model/launch_merchant_model.dart';
import 'package:fawry_sdk/model/payment_methods.dart';
import 'package:fawry_sdk/model/response.dart';
```

### Streaming Result Data

You can stream the result data that comes from the Fawry SDK to handle different response scenarios using Flutter's stream functionality. Here's how you can achieve this:

```dart
// Add this code in your Dart file
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
```

This will enable you to handle different responses and outcomes from the Fawry SDK in a more dynamic way. The `handleResponse` method is where you can customize your actions based on the response status.

---

## SDK Initialization

### Building FawryLaunchModel

The `FawryLaunchModel` is essential to initialize the Fawry SDK. It contains both mandatory and optional parameters needed for the payment process.

#### LaunchCustomerModel (Optional) Parameters:

1. `customerName` (optional)
2. `customerEmail` (optional - Receives an email with the receipt after payment completion)
3. `customerMobile` (optional - Receives an SMS with the reference number and payment details)

#### ChargeItem Parameters:

1. `Price` (mandatory)
2. `Quantity` (mandatory)
3. `itemId` (mandatory)
4. `Description` (optional)

#### LaunchMerchantModel Parameters:

1. `merchantCode` (provided by support – mandatory)
2. `merchantRefNum` (random 10 alphanumeric digits – mandatory)
3. `secureKey` (provided by support – mandatory)

#### Other Parameters:

1. `allow3DPayment` (to allow 3D Secure payment)
2. `secretCode` (provided by support)
3. `signature` (generated by you)
4. `skipLogin` (can skip login screen that takes email and mobile, default value is true)
5. `skipReceipt` (to skip the receipt screen, default value is false)
6. `payWithCardToken` (Enables/disables user card tokenization; if enabled, define `customerProfileId` in LaunchCustomerModel)
7. `paymentMethods` (optional; controls payment methods displayed to the user, e.g., `PaymentMethods.CREDIT_CARD` , `PaymentMethods.ALL` )

### Example

```dart
 
BillItem item = BillItem(
  itemId: 'Item1',
  description: 'Book',
  quantity: 6,
  price: 50,
);

List<BillItem> chargeItems = [item];

LaunchCustomerModel customerModel = LaunchCustomerModel(
  customerProfileId: '533518',
  customerName: 'John Doe',
  customerEmail: 'john.doe@xyz.com',
  customerMobile: '+201000000000',
);

LaunchMerchantModel merchantModel = LaunchMerchantModel(
  merchantCode: 'YOUR MERCHANT CODE',
  merchantRefNum: FawryUtils.randomAlphaNumeric(10),
  secureKey: 'YOUR SECURE KEY',
);

FawryLaunchModel model = FawryLaunchModel(
  allow3DPayment: true,
  chargeItems: chargeItems,
  launchCustomerModel: customerModel,
  launchMerchantModel: merchantModel,
  skipLogin: true,
  skipReceipt: true,
  payWithCardToken: false,
  paymentMethods: PaymentMethods.ALL,
);

String baseUrl = "https://atfawry.fawrystaging.com/";
```


### Start Payment

```dart
Future<void> startPayment() async {
  await FawrySDK.instance.startPayment(
    launchModel: model,
    baseURL: baseUrl,
    lang: FawrySDK.LANGUAGE_ENGLISH,
  );
}
```

### Open Cards Manager

```dart
Future<void> openCardsManager() async {
  await FawrySDK.instance.openCardsManager(
    launchModel: model,
    baseURL: baseUrl,
    lang: FawrySDK.LANGUAGE_ENGLISH,
  );
}
```

---

## Customizing UI Colors

### Android

1. Navigate to `android > app > src > main > res > values`.

2. Create a new file named `colors.xml`.

3. Add color values to `colors.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="fawry_blue">#6F61C0</color> <!-- Set your primary color hex code -->
    <color name="fawry_yellow">#A084E8</color> <!-- Set your secondary color hex code -->
</resources>
```

### iOS

1. In your project, navigate to `ios > Runner`.

2. Create a new file named `Style.plist`.

3. Add color values to `Style.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>primaryColorHex</key>
    <string>#6F61C0</string> <!-- Set your primary color hex code -->
    <key>secondaryColorHex</key>
    <string>#A084E8</string> <!-- Set your secondary color hex code -->
    <key>tertiaryColorHex</key>
    <string>#8BE8E5</string> <!-- Set your tertiary color hex code -->
    <key>headerColorHex</key>
    <string>#6F61C0</string> <!-- Set your header color hex code -->
</dict>
</plist>
```

4. In Xcode, right-click on the `Runner`, select "Add Files to 'Runner'", and add the `Style.plist` file.

## Troubleshooting Release Mode

If you experience an issue in release mode not present in debug mode, you can address it by adding these rules to your Android app's `build.gradle`:

```groovy
// ... (previous code)

buildTypes {
    release {
        minifyEnabled false
        shrinkResources false
        // ...
    }
}
```

## Sample Project

For a practical demonstration of Fawry SDK integration in a Flutter app, explore our sample project on GitHub:

[**Flutter Fawrypay Anonymous Sample**](https://github.com/FawryPay/Flutter-Fawrypay-Anonymous-sample)

This project showcases the usage and seamless integration of the Fawry SDK for secure payment processing in your Flutter applications.

---

Feel free to dive into the sample project and leverage the guide to effortlessly integrate the Fawry SDK into your Flutter app.
