import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'privacy_screen_platform_interface.dart';
import 'privacy_screen_state.dart';
import 'privacy_helpers.dart';

class PrivacyScreen {
  static final PrivacyScreen _instance = PrivacyScreen._init();
  PrivacyScreen._();

  static PrivacyScreen _init() {
    _channel.setMethodCallHandler(_callHandler);
    return PrivacyScreen._();
  }

  static Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case "lock":
        if (!instance.lockPaused) {
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

  final ValueNotifier<bool> lockNotifier = ValueNotifier(false);

  // final PrivacyStateNotifier stateNotifier = PrivacyStateNotifier();

  final ValueNotifier<PrivacyScreenState> stateNotifier =
      ValueNotifier(const PrivacyScreenState());

  final ValueNotifier<AppLifeCycle> lifeCycleNotifier =
      ValueNotifier(AppLifeCycle.unknown);

  bool _lockPaused = false;
  bool get lockPaused => _lockPaused;

  void pauseLock() {
    _lockPaused = true;
  }

  void resumeLock() {
    _lockPaused = false;
  }

  bool get shouldLock => lockNotifier.value;

  PrivacyIosOptions get iosOptions => stateNotifier.value.iosOptions;
  PrivacyAndroidOptions get androidOptions =>
      stateNotifier.value.androidOptions;
  PrivacyBlurEffect get blurEffect => stateNotifier.value.blurEffect;
  Color get backgroundColor => stateNotifier.value.backgroundColor;
  AppLifeCycle get appLifeCycle => lifeCycleNotifier.value;

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
      stateNotifier.value = stateNotifier.value.copyWith(
        androidOptions: androidOptions,
        iosOptions: iosOptions,
        backgroundColor: backgroundColor,
        blurEffect: blurEffect,
      );
    }
    return result;
  }

  Future<bool> disable() async {
    final PrivacyScreenState targetValue = stateNotifier.value.copyWith(
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
      stateNotifier.value = targetValue;
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

  void lock() {
    if (!instance.lockNotifier.value) {
      instance.lockNotifier.value = true;
    }
  }

  void unlock() {
    if (instance.lockNotifier.value) {
      instance.lockNotifier.value = false;
    }
  }

  void _updateLifeCycleStatus(dynamic value) {
    instance.lifeCycleNotifier.value = _toAppLifeCycle(value);
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
}
