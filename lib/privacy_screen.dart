library privacy_screen;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'privacy_screen_platform_interface.dart';
import 'privacy_screen_state.dart';
import 'src/privacy_helpers.dart';
export 'src/privacy_helpers.dart';
export 'src/privacy_gate.dart';

class PrivacyScreen extends ValueNotifier<PrivacyScreenState> {
  static final PrivacyScreen _instance = PrivacyScreen._init();
  PrivacyScreen._() : super(const PrivacyScreenState());

  static PrivacyScreen _init() {
    _channel.setMethodCallHandler(_callHandler);
    return PrivacyScreen._();
  }

  static Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case "lock":
        if (!instance.value.lockPaused) {
          instance.lock();
        }
        return true;
      case "onLifeCycle":
        instance._updateLifeCycleStatus(call.arguments);
        return true;
      default:
        return;
    }
  }

  static PrivacyScreen get instance => _instance;

  static const MethodChannel _channel =
      MethodChannel('channel.couver.privacy_screen');

  final BehaviorSubject<AppLifeCycle> _appLifeCycleEventsCtrl =
      BehaviorSubject<AppLifeCycle>.seeded(AppLifeCycle.unknown);

  Stream<AppLifeCycle> get appLifeCycleEvents => _appLifeCycleEventsCtrl.stream;

  bool get shouldLock => value.shouldLock;

  PrivacyIosOptions get iosOptions => value.iosOptions;

  PrivacyAndroidOptions get androidOptions => value.androidOptions;

  PrivacyBlurEffect get blurEffect => value.blurEffect;

  Color get backgroundColor => value.backgroundColor;

  Future<bool> enable({
    /// Options for ios
    PrivacyIosOptions iosOptions = const PrivacyIosOptions(),

    /// Options for Android
    PrivacyAndroidOptions androidOptions = const PrivacyAndroidOptions(),

    /// This will be the backgroundColor of the overlay privacyView
    /// (Also the background color if you choose to use [privacyImageName])
    /// It can also be an translucent color
    Color backgroundColor = const Color(0xffffffff),

    /// A blur effect for PrivacyView on IOS
    /// and the locker's background
    PrivacyBlurEffect blurEffect = PrivacyBlurEffect.extraLight,
  }) async {
    final bool result = await _updateNative(
      iosOptions: iosOptions,
      androidOptions: androidOptions,
      backgroundColor: backgroundColor,
      blurEffect: blurEffect,
    );
    if (result) {
      value = value.copyWith(
        androidOptions: androidOptions,
        iosOptions: iosOptions,
        backgroundColor: backgroundColor,
        blurEffect: blurEffect,
      );
      notifyListeners();
    }
    return result;
  }

  Future<bool> disable() async {
    final PrivacyScreenState targetValue = value.copyWith(
      androidOptions: PrivacyAndroidOptions.disable(),
      iosOptions: PrivacyIosOptions.disable(),
    );

    final bool result = await _updateNative(
      iosOptions: targetValue.iosOptions,
      androidOptions: targetValue.androidOptions,
      backgroundColor: const Color(0xffffffff),
      blurEffect: PrivacyBlurEffect.none,
    );
    if (result) {
      value = targetValue;
      notifyListeners();
    }
    return result;
  }

  Future<bool> _updateNative({
    required PrivacyIosOptions iosOptions,
    required PrivacyAndroidOptions androidOptions,
    required Color backgroundColor,
    required PrivacyBlurEffect blurEffect,
  }) async {
    final bool? result = await PrivacyScreenPlatform.instance.updateConfig(
      iosOptions: iosOptions,
      androidOptions: androidOptions,
      backgroundColor: backgroundColor,
      blurEffect: blurEffect,
    );
    return result ?? false;
  }

  lock() {
    value = value.copyWith(shouldLock: true);
    notifyListeners();
  }

  unlock() {
    value = value.copyWith(shouldLock: false);
    notifyListeners();
  }

  pauseLock() {
    if (!value.lockPaused) {
      value = value.copyWith(lockPaused: true);
      notifyListeners();
    }
  }

  resumeLock() {
    if (value.lockPaused) {
      value = value.copyWith(lockPaused: false);
      notifyListeners();
    }
  }

  _updateLifeCycleStatus(dynamic value) {
    _appLifeCycleEventsCtrl.add(_toAppLifeCycle(value));
  }

  AppLifeCycle _toAppLifeCycle(dynamic value) {
    if (value is String) {
      switch (value) {
        case "applicationDidBecomeActive":
          return AppLifeCycle.iosDidBecomeActive;
        case "applicationDidEnterBackground":
          return AppLifeCycle.iosDidEnterBackground;
        case "applicationWillEnterForeground":
          return AppLifeCycle.iosWillEnterForeground;
        case "applicationWillResignActive":
          return AppLifeCycle.iosWillResignActive;
        case "onResume":
          return AppLifeCycle.androidOnResume;
        case "onDestroy":
          return AppLifeCycle.androidOnDestroy;
        case "onPause":
          return AppLifeCycle.androidOnPause;
        case "onStop":
          return AppLifeCycle.androidOnStop;
        case "onStart":
          return AppLifeCycle.androidOnStart;
        case "onCreate":
          return AppLifeCycle.androidOnCreate;
      }
    }
    return AppLifeCycle.unknown;
  }

  @override
  void dispose() {
    _appLifeCycleEventsCtrl.close();
    super.dispose();
  }
}
