# Fawry SDK Integration Guide

The Fawry SDK is a cross-platform plugin that facilitates the integration of your app with Fawry's native Android and iOS SDKs, enabling seamless payment integration.

## Getting Started

Add the Fawry SDK plugin to your Flutter project's dependencies by adding the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  fawry_sdk: ^1.0.9
```

### Android Setup

1. Edit your `AndroidManifest.xml` file by adding the following code snippet inside the `<application>` tag:

```xml
<application
    android:allowBackup="false"
    android:icon="@mipmap/ic_launcher"
    android:label="Your App Label"
    tools:replace="android:label">
    <!-- if you're not defining a label, remove 'android:label' from tools:replace -->
</application>
```

2. Update the **minimum SDK version** to be **21** or higher in your `build.gradle` file:

```groovy
android {
    compileSdkVersion flutter.compileSdkVersion
    minSdkVersion 21
    // ...
}
```

### iOS Setup

1. Set the minimum iOS version under "Deployment info" to 12.1 or higher in your `Runner` project in Xcode.

**NOTE:** The plugin currently supports only real devices. Simulators will be supported in later versions of the SDK.

## Usage

### Initializing the SDK

To initialize the Fawry SDK, follow these steps:

1. Import the Fawry SDK package in your Dart code:

```dart
import 'package:fawry_sdk/fawry_sdk.dart';
```

2. Initialize the SDK by passing the required parameters using the `FawrySdk.instance.init()` method:

```dart
await FawrySdk.instance.init(
  launchModel: fawryLaunchModel,
  baseURL: "BASE_URL",
  lang: FawrySdk.LANGUAGE_ENGLISH or FawrySdk.LANGUAGE_ARABIC,
);
```

### Building FawryLaunchModel

The `FawryLaunchModel` is essential for initializing the Fawry SDK. It contains various attributes for the payment process.

Example of creating a `FawryLaunchModel`:

```dart
// Create a charge item
BillItem item = BillItem(
  itemId: "ITEM_ID",
  description: "",
  quantity: 4,
  price: 15,
);

// Create a customer model
LaunchCustomerModel customerModel = LaunchCustomerModel(
  customerName: "John Doe",
  customerEmail: "john.doe@xyz.com",
  customerMobile: "+201000000000",
);

// Create a merchant model
LaunchMerchantModel merchantModel = LaunchMerchantModel(
  merchantCode: "MERCHANT_CODE",
  merchantRefNum: "MERCHANT_REF_NUM",
  secureKey: "SECURE_KEY or SECRET_CODE",
);

// Create the FawryLaunchModel
FawryLaunchModel model = FawryLaunchModel(
  allow3DPayment: true,
  chargeItems: [item],
  launchCustomerModel: customerModel,
  launchMerchantModel: merchantModel,
  skipLogin: true,
  skipReceipt: false,
  payWithCardToken: false,
  paymentMethods: PaymentMethods.ALL,
);
```

### Customizing UI Colors - Android

To customize UI colors on Android, follow these steps:

1. Navigate to `android > app > src > main > res > values`.

2. Create a new file called `colors.xml`.

3. Add the following content to `colors.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="fawry_blue">#6F61C0</color> <!-- Set your primary color hex code -->
    <color name="fawry_yellow">#A084E8</color> <!-- Set your secondary color hex code -->
</resources>
```

### Customizing UI Colors - iOS

To customize UI colors on iOS, follow these steps:

1. In your project, navigate to `ios > Runner`.

2. Create a new file called `Style.plist`.

3. Add the following content to `Style.plist`:

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

4. In Xcode, right-click on the `Runner` folder, select "Add Files to 'Runner'", and add the `Style.plist` file.

These steps will allow you to customize the UI colors of the Fawry SDK integration on both Android and iOS platforms.
