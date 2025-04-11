import 'dart:ui' show Color;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'privacy_helpers.dart';
import 'privacy_screen_method_channel.dart';

abstract class PrivacyScreenPlatform extends PlatformInterface {
  /// Constructs a PrivacyScreenPlatform.
  PrivacyScreenPlatform() : super(token: _token);

  static final Object _token = Object();

  static PrivacyScreenPlatform _instance = MethodChannelPrivacyScreen();

  /// The default instance of [PrivacyScreenPlatform] to use.
  ///
  /// Defaults to [MethodChannelPrivacyScreen].
  static PrivacyScreenPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PrivacyScreenPlatform] when
  /// they register themselves.
  static set instance(PrivacyScreenPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> updateConfig({
    required PrivacyIosOptions iosOptions,
    required PrivacyAndroidOptions androidOptions,
    required Color backgroundColor,
    required PrivacyBlurEffect blurEffect,
  }) {
    throw UnimplementedError('updateConfig() has not been implemented.');
  }
}
