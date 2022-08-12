import 'package:flutter/material.dart';
import 'dart:async';

import 'package:privacy_screen/privacy_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        onPressed: () =>
                            launchUrl(Uri.parse("https://www.flutter.dev/")),
                        child: const Text("Test Native: Url Launch"),
                      ),
                      const Divider(),
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
                            blurEffect: PrivacyBlurEffect.light,
                          );
                        },
                        child: const Text("Enable light"),
                      ),

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
                            backgroundColor: Colors.red.withOpacity(0.4),
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
                      // StreamBuilder(
                      //   stream: PrivacyScreen.instance.appLifeCycleEvents,
                      //   builder: (context, snapshot) =>
                      //       Text('Last LifeCycle: ${snapshot.data}'),
                      // ),
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
