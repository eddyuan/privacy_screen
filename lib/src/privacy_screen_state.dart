import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'privacy_helpers.dart';

@immutable
class PrivacyScreenState {
  final PrivacyIosOptions iosOptions;
  final PrivacyAndroidOptions androidOptions;
  final PrivacyBlurEffect blurEffect;
  final Color backgroundColor;

  const PrivacyScreenState({
    this.iosOptions = const PrivacyIosOptions(),
    this.androidOptions = const PrivacyAndroidOptions(),
    this.blurEffect = PrivacyBlurEffect.extraLight,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  PrivacyScreenState copyWith({
    bool? shouldLock,
    PrivacyIosOptions? iosOptions,
    PrivacyAndroidOptions? androidOptions,
    PrivacyBlurEffect? blurEffect,
    Color? backgroundColor,
  }) {
    return PrivacyScreenState(
      androidOptions: androidOptions ?? this.androidOptions,
      iosOptions: iosOptions ?? this.iosOptions,
      blurEffect: blurEffect ?? this.blurEffect,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}
