import 'package:flutter/material.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'dart:async';

import 'package:privacy_screen/privacy_gate.dart';
import 'package:privacy_screen/privacy_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the Intercom.
  // make sure to add keys from your Intercom workspace.
  await Intercom.instance.initialize(
    't0ee6c01',
    iosApiKey: 'ios_sdk-dd5922ffff4faad3682c1dd8931d4b473615332f',
    androidApiKey: 'android_sdk-324cdf713806c0c3f97accc6bc60b420010714a0',
  );
  Intercom.instance.loginUnidentifiedUser();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      launchUrl(Uri.parse(
                          "https://www.instagram.com/couverfinancial/"));
                    },
                    child: Text("Url Launch"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Intercom.instance.displayHelpCenter();
                    },
                    child: Text("Goto Intercom"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Intercom.instance.displayHelpCenter();
                    },
                    child: Text("Goto Intercom"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      PrivacyScreen.instance.enable(
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
                      PrivacyScreen.instance.enable(
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
                      PrivacyScreen.instance.enable(
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
                        blurEffect: PrivacyBlurEffect.dark,
                      );
                    },
                    child: const Text("Enable dark"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      PrivacyScreen.instance.disable();
                    },
                    child: const Text("Disable"),
                  ),
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
                ],
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
