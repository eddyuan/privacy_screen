import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'src/privacy_helpers.dart';

/// state hold by the [SecureApplicationController]
@immutable
class PrivacyScreenState {
  final PrivacyIosOptions iosOptions;
  final PrivacyAndroidOptions androidOptions;
  final bool shouldLock;
  final bool lockPaused;
  final PrivacyBlurEffect blurEffect;
  final Color backgroundColor;

  const PrivacyScreenState({
    this.iosOptions = const PrivacyIosOptions(),
    this.androidOptions = const PrivacyAndroidOptions(),
    this.shouldLock = false,
    this.lockPaused = false,
    this.blurEffect = PrivacyBlurEffect.extraLight,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  PrivacyScreenState copyWith({
    bool? shouldLock,
    PrivacyIosOptions? iosOptions,
    PrivacyAndroidOptions? androidOptions,
    PrivacyBlurEffect? blurEffect,
    bool? lockPaused,
    Color? backgroundColor,
    // bool? enable,
  }) {
    return PrivacyScreenState(
      shouldLock: shouldLock ?? this.shouldLock,
      androidOptions: androidOptions ?? this.androidOptions,
      iosOptions: iosOptions ?? this.iosOptions,
      lockPaused: lockPaused ?? this.lockPaused,
      blurEffect: blurEffect ?? this.blurEffect,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
