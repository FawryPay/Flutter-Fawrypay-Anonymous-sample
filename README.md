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

#### How it works
![Fawrypay SDK Explained](https://raw.githubusercontent.com/FawryPay/Android-Fawrypay-Anonymous-sample/master/Docs/4.jpg)

### Adding Fawry SDK Plugin

To begin, add the Fawry SDK plugin to your Flutter project's dependencies. Open your `pubspec.yaml` file and add the following line:

```yaml
dependencies:
  fawry_sdk: ^2.0.11
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

<br/>LaunchCustomerModel

| **PARAMETER**     | **TYPE** | **REQUIRED** | **DESCRIPTION**                                 | **EXAMPLE**                                        |
|---------------|---------------|---------------|---------------|---------------|
| customerName      | String   | optional     | \-                                              | Name Name                                          |
| customerEmail     | String   | optional     | \-                                              | [email\@email.com](mailto:email@email.com){.email} |
| customerMobile    | String   | optional     | \-                                              | +0100000000                                        |
| customerProfileId | String   | optional     | mandatory in case of payments using saved cards | 1234                                               |

<br/>LaunchMerchantModel

| **PARAMETER**  | **TYPE** | **REQUIRED**        | **DESCRIPTION**                                                           | **EXAMPLE**           |
|---------------|---------------|---------------|---------------|---------------|
| merchantCode   | String   | required            | Merchant ID provided during FawryPay account setup.                       | +/IPO2sghiethhN6tMC== |
| merchantRefNum | String   | required            | Merchant's transaction reference number is random 10 alphanumeric digits. | A1YU7MKI09            |
| secretKey     | String   | required            | provided by support                                                       | 4b8jw3j2-8gjhfrc-4wc4-scde-453dek3d |

<br/>ChargeItemsParamsModel

| **PARAMETER** | **TYPE** | **REQUIRED** | **DESCRIPTION** | **EXAMPLE**         |
|---------------|---------------|---------------|---------------|---------------|
| itemId        | String   | required     | \-              | 3w8io               |
| description   | String   | optional     | \-              | This is description |
| price         | String   | required     | \-              | 200.00              |
| quantity      | String   | required     | \-              | 1                   |

<br/>FawryLaunchModel

| **PARAMETER**           | **TYPE**   | **REQUIRED** | **DESCRIPTION** | **EXAMPLE** |
|---------------|---------------|---------------|---------------|---------------|
| **launchCustomerModel** | LaunchCustomerModel | optional | Customer information.         | \-          |
| **launchMerchantModel** | LaunchMerchantModel | required | Merchant information.         | \-          |
| **chargeItems**         | [ChargeItemsParamsModel]      | required       | Array of items which the user will buy, this array must be of type ChargeItemsParamsModel  | \-          |
| signature               | String    | optional  | You can create your own signature by concatenate the following elements on the same order and hash the result using **SHA-256** as explained:"merchantCode + merchantRefNum + customerProfileId (if exists, otherwise insert"") + itemId + quantity + Price (in tow decimal format like '10.00') + Secure hash keyIn case of the order contains multiple items the list will be **sorted** by itemId and concatenated one by one for example itemId1+ Item1quantity + Item1price + itemId2 + Item2quantity + Item2price | \-          | 
| allowVoucher            | Boolean  | optional - default value = false  | True if your account supports voucher code | \-          |
| payWithCardToken        | Boolean   | required   | If true, the user will pay with a card token ( one of the saved cards or add new card to be saved )If false, the user will pay with card details without saving | \-   | 
| allow3DPayment          | Boolean                 | optional - default value = false | to allow 3D secure payment make it "true" | \-    |
| skipReceipt             | Boolean                 | optional - default value = false      | to skip receipt after payment trial      | \-          |
| skipLogin               | Boolean                          | optional - default value = true  | to skip login screen in which we take email and mobile   | \-          |
| authCaptureMode         | Boolean                          | optional - default value = false                                                                                                                                | depends on refund configuration: will be true when refund is enabled and false when refund is disabled                                                                                             | false       |
| paymentMethod        | PaymentMethods         | Optional - default value = .ALL | If the user needs to show only one payment method. | PaymentMethods.ALL |

<br/>Additional Required Parameters

| PARAMETER  | TYPE    | REQUIRED | DESCRIPTION | EXAMPLE |
|------------|---------|----------|-------------|---------|
| **baseUrl** | String  | required | Provided by the support team. Use the staging URL for testing and switch for production to go live. | Staging: `https://atfawry.fawrystaging.com/`<br/>Production: `https://atfawry.com/` |
| **lang**   | String  | required | SDK language which will affect the SDK's interface languages. | `FawrySDK.LANGUAGE_ENGLISH` |



**Notes:**

-   **you can pass either signature or secureKey (in this case we will create the signature internally), knowing that if the 2 parameters are passed the secureKey will be ignored and the signature will be used.**

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
