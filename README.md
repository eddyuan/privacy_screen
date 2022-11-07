# privacy_screen

Flutter plugin to provide a privacy screen feature (hide content when app is in background)

Pluggin in iOS is in swift

Pluggin in Android is in Kotlin

**This plugin used native app lifeCycles instead of flutter's to ensure it works when flutter entered a native view (eg: from a native plugin)**

This plugin also provides a native life cycle listener through `instance.appLifeCycleEvents` stream

## Features

| IOS                | Android                | Feature                                 |
| ------------------ | ---------------------- | --------------------------------------- |
| :heavy_check_mark: | :x:                    | Custom privacy screen image / Blurr Effect             |
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

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_0.gif?raw=true" height="400" /><img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_1.png?raw=true" height="400" /><img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/ios_2.png?raw=true" height="400" />

## Android

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/android_1.png?raw=true" height="400" /><img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/android_2.png?raw=true" height="400" />

## Usage

### Installation

Add `privacy_screen` as a dependency in your `pubspec.yaml` file.

### Import

```
import 'package:privacy_screen/privacy_screen.dart';
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

Open your project's ios folder with XCode and add the image asset in the runner/assets

The `privacyImageName` String must match the asset name, eg: `"LaunchImage"`

<img src="https://github.com/eddyuan/privacy_screen/blob/master/screen_shots/xcode_setting.png?raw=true" width="100%" />

## To use the lock feature

Put `PrivacyGate` widget at your root and provide your own `lockBuilder` widget.

### Option 1

Use it at MaterialApp's builder and provide a `navigatorKey`.

By providing `navigatorKey`, the plugin will put your `lockBuilder` into a new `Route`, and you can write `WillPopScope` in your `lockBuilder` to prevent navigation once entered the lock screen.

```dart
// Your MaterialApp
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  // Give it a key to use route
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Give it a key
      navigatorKey: navigatorKey,
      builder: (_, child) {
        return PrivacyGate(
          lockBuilder: (ctx) => const LockerPage(),
          // Give it a key
          navigatorKey: navigatorKey,
          onLifeCycleChanged: (value) => print(value),
          onLock: () => print("onLock"),
          onUnlock: () => print("onUnlock"),
          child: child,
        );
      },
      home: const FirstRoute(),
    );
  }
}
```

```dart
// Your LockerPage
class LockerPage extends StatelessWidget {
  const LockerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result = await showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirmation",
                    style: TextStyle(fontSize: 24),
                  ),
                  const Text("Are you sure to unlock?"),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (result == true) {
          PrivacyScreen.instance.unlock();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(),
              ElevatedButton(
                child: const Text("Unlock"),
                onPressed: () => PrivacyScreen.instance.unlock(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Option 2

Without providing `navigatorKey`, the plugin will put your lock in `Stack` with your app. This method can not handle hardware back button thus even the lock is showing, user can still navigate away by pressing the hardware back button on android.

### Option 3

Without providing `lockBuilder`, you can use `onLock` and `onUnlock` event trigger to write you own lock mechanisms, just make sure you use `instance.unlock` to reset the locker properly.

### Manual Lock

```dart
PrivacyScreen.instance.lock();
```

### Unlock

```dart
PrivacyScreen.instance.unlock();
```

### Pause auto lock

This will pause the auto lock until resume.

It's is usefull when you set lockTrigger as `IosLockTrigger.willResignActive` because actions like swipe down to show system menu and authenticate with faceID will also trigger the `willResignActive` action (you don't want to lock it right after faceID unlock.. maybe? so you can pause before faceID and resume after faceID done)

```dart
PrivacyScreen.instance.pauseLock();
```

### Resume auto lock

```dart
PrivacyScreen.instance.resumeLock();
```

## Parameters

When calling `instance.enable()`, configurations can be provided:

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
| privacyImageName     | The name of the native IOS runner asset you want to show on the privacy view. Leave empty if you don't want to show an image                              |
| lockTrigger          | What native event should trigger the lock mechanism. Try avoid using IosLockTrigger.willResignActive                                                      |

### Android options

| param                | feature                                                                                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| enableSecure         | Add FLAG_SECURE to android (Hide content and disable screenshot)                                                                                              |
| autoLockAfterSeconds | Trigger lock when coming back (x) seconds after enter background. This is seperated from enableSecure, so you can disable FLAG_SECURE and still use auto lock |

### Full Example (Because you all want to see in Readme)

```dart
import 'package:flutter/material.dart';
import 'package:privacy_screen/privacy_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (_, child) {
        return PrivacyGate(
          lockBuilder: (ctx) => const LockerPage(),
          navigatorKey: navigatorKey,
          onLifeCycleChanged: (value) => print(value),
          onLock: () => print("onLock"),
          onUnlock: () => print("onUnlock"),
          child: child,
        );
      },
      home: const FirstRoute(),
    );
  }
}

class FirstRoute extends StatefulWidget {
  const FirstRoute({Key? key}) : super(key: key);

  @override
  State<FirstRoute> createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  List<String> lifeCycleHistory = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () =>
                        launchUrl(Uri.parse("https://www.flutter.dev/")),
                    child: const Text("Test Native: Url Launch"),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.enable(
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
                      await PrivacyScreen.instance.enable(
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
                        blurEffect: PrivacyBlurEffect.light,
                      );
                    },
                    child: const Text("Enable light"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.enable(
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
                        backgroundColor: Colors.red.withOpacity(0.4),
                        blurEffect: PrivacyBlurEffect.dark,
                      );
                    },
                    child: const Text("Enable dark"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.disable();
                    },
                    child: const Text("Disable"),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () {
                      PrivacyScreen.instance.lock();
                    },
                    child: const Text("Lock"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      PrivacyScreen.instance.pauseLock();
                    },
                    child: const Text("Pause Auto Lock"),
                  ),
                  ElevatedButton(
                    onPressed: () {
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
    );
  }
}

class LockerPage extends StatelessWidget {
  const LockerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result = await showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirmation",
                    style: TextStyle(fontSize: 24),
                  ),
                  const Text("Are you sure to unlock?"),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (result == true) {
          PrivacyScreen.instance.unlock();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(),
              ElevatedButton(
                child: const Text("Unlock"),
                onPressed: () => PrivacyScreen.instance.unlock(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
