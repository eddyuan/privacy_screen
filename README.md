# privacy_screen

Flutter plugin to provide a privacy screen feature (hide content when app is in background)

Pluggin in iOS is in swift

Pluggin in Android is in Kotlin

**This plugin used native app lifeCycles instead of flutter's to ensure it works when flutter entered a native view (eg: from a native plugin)**

This plugin also provides a native life cycle listener through `instance.appLifeCycleEvents` stream

## Features

| IOS                | Android                | Feature                                 |
| ------------------ | ---------------------- | --------------------------------------- |
| :heavy_check_mark: | :x:                    | Custom privacy screen image             |
| :x:                | Mandatory when enabled | Disable screenshot                      |
| :heavy_check_mark: | :heavy_check_mark:     | Auto lock trigger with native lifecycle |
| :heavy_check_mark: | :heavy_check_mark:     | Native lifecycle listener               |

## Cons

- IOS

  - The lock can not be presented when app is currently showing a native view (eg: from a native plugin like urlLauncher), due to Flutter's view (The lock widget) can not go on top of the native view controller. However, the privacy view will always work (because it's native)

- Android
  - FLAG_SECURE currently only on flutter window so it won't work in a native view until back to flutter window.
  - Can not customize privacy view. FLAG_SECURE will disable screenshot and show a black/white screen when app entered background. If you want to enable screen shot and still use privacy view, there's no way on android to do as far as I know.

## IOS

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_0.gif?raw=true" height="400" />
<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_1.png?raw=true" height="400" />
<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_2.png?raw=true" height="400" />

## Android

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/android_1.png?raw=true" height="400" />
<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/android_2.png?raw=true" height="400" />

## Usage

### Installation

Add `privacy_screen` as a dependency in your `pubspec.yaml` file ([what?](https://pub.dev/packages/secure_application#-installing-tab-)).

### Import

```
import 'package:secure_application/secure_application.dart';
```

And then you can simply call functions of PrivacyScreen class instance anywhere

## To enable privacy view

```dart
bool result = await PrivacyScreen.instance.enable(
    iosOptions: const PrivacyIosOptions(
        enablePrivacy: true,
        privacyImageName: "LaunchImage",
        autoLockAfterSeconds: 5,
        lockTrigger: IosLockTrigger.didEnterBackground,
    ),
    androidOptions: const PrivacyAndroidOptions(
        enableSecure: true,
        autoLockAfterSeconds: 5,
    ),
    backgroundColor: Colors.white.withOpacity(0),
    blurEffect: PrivacyBlurEffect.extraLight,
);
```

## To disable privacy view

```dart
bool result = await PrivacyScreen.instance.disable();
```

## To use custom image on IOS

Supply `privacyImageName` in iosOptions

Open your project's ios folder with xCode and add the image asset in the runner/assets

The `privacyImageName` String must match the asset name, eg: `"LaunchImage"`

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/xcode_setting.png?raw=true" width="100%" />

## To use the lock feature

Put `PrivacyGate` widget at your root and provide your own `lockBuilder` widget.

### To lock

```dart
PrivacyScreen.instance.lock();
```

### To unlock

```dart
PrivacyScreen.instance.unlock();
```

### Example (Because you all want to see in Readme)

```dart
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> lifeCycleHistory = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PrivacyScreen.instance.appLifeCycleEvents.listen((event) {
      lifeCycleHistory.add('$event');
      setState(() {});
    });
    initPlatformState();
  }

  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrivacyGate(
        lockBuilder: (context) => LockerPage(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool result = await PrivacyScreen.instance.enable(
                            iosOptions: const PrivacyIosOptions(
                              enablePrivacy: true,
                              privacyImageName: "LaunchImage",
                              autoLockAfterSeconds: 5,
                              lockTrigger: IosLockTrigger.didEnterBackground,
                            ),
                            androidOptions: const PrivacyAndroidOptions(
                              enableSecure: true,
                              autoLockAfterSeconds: 5,
                            ),
                            backgroundColor: Colors.white.withOpacity(0),
                            blurEffect: PrivacyBlurEffect.extraLight,
                          );
                        },
                        child: const Text("Enable extraLight"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          PrivacyScreen.instance.disable();
                        },
                        child: const Text("Disable"),
                      ),
                      const Divider(),
                      ElevatedButton(
                        onPressed: () async {
                          PrivacyScreen.instance.lock();
                        },
                        child: const Text("Lock"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          PrivacyScreen.instance.pauseLock();
                        },
                        child: const Text("Pause Auto Lock"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          PrivacyScreen.instance.pauseLock();
                        },
                        child: const Text("Resume Auto Lock"),
                      ),
                      const Divider(),
                      ...lifeCycleHistory.map((e) => Text(e)).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LockerPage extends StatefulWidget {
  const LockerPage({Key? key}) : super(key: key);

  @override
  State<LockerPage> createState() => _LockerPageState();
}

class _LockerPageState extends State<LockerPage> {
  @override
  void initState() {
    print("Locker InitState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text("Unlock"),
        onPressed: () {
          PrivacyScreen.instance.unlock();
        },
      ),
    );
  }
}
```

## Parameters

When you call `enable()`, you can provide configurations, here's what they do

### Shared options

| param           | feature                                                                          |
| --------------- | -------------------------------------------------------------------------------- |
| backgroundColor | Background color of the privacy view on IOS, and of the locker on both platforms |
| blurEffect      | The blurEffect used according to IOS's blurEffect.                               |

### IOS options

| param                | feature                                                                                                                                                   |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| enablePrivacy        | Enable the privacy view when app goes into background                                                                                                     |
| autoLockAfterSeconds | Trigger lock when coming back (x) seconds after enter background. This is seperated from enablePriacy, so you can disable privacy and still use auto lock |
| privacyImageName     | The name of the native IOS runner asset you want to show on the privacy view                                                                              |
| lockTrigger          | What native event should trigger the lock mechanism. Try avoid using IosLockTrigger.willResignActive                                                      |

### Android options

| param                | feature                                                                                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| enableSecure         | Add FLAG_SECURE to android (Hide content and disable screenshot)                                                                                              |
| autoLockAfterSeconds | Trigger lock when coming back (x) seconds after enter background. This is seperated from enableSecure, so you can disable FLAG_SECURE and still use auto lock |
