import 'dart:ui';

enum IosLockTrigger { willResignActive, didEnterBackground }

enum PrivacyBlurEffect {
  light,
  extraLight,
  dark,
  none,
}

extension PrivacyBlurEffectExtension on PrivacyBlurEffect {
  Color get color {
    switch (this) {
      case PrivacyBlurEffect.dark:
        return const Color.fromARGB(144, 0, 0, 0);
      case PrivacyBlurEffect.none:
        return const Color(0x00FFFFFF);
      default:
        return const Color.fromARGB(50, 255, 255, 255);
    }
  }

  double get blurRadius {
    switch (this) {
      case PrivacyBlurEffect.extraLight:
        return 32;
      case PrivacyBlurEffect.none:
        return 0;
      default:
        return 18;
    }
  }
}

enum AppLifeCycle {
  iosDidBecomeActive,
  iosDidEnterBackground,
  iosWillEnterForeground,
  iosWillResignActive,
  androidOnResume,
  androidOnDestroy,
  androidOnPause,
  androidOnStop,
  androidOnStart,
  androidOnCreate,
  unknown,
}

AppLifeCycle toAppLifeCycle(dynamic value) {
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

class PrivacyAndroidOptions {
  const PrivacyAndroidOptions({
    /// This will add [FLAG_SECURE] for android
    /// Which will hide app content in background
    /// and also disable screenshot for the whole app
    this.enableSecure = true,

    /// Enable auto lock, this is irrelevant with [enableSecure]
    /// You can disable [enableSecure] and still enable auto locker
    /// Disabled when <0, enable when >= 0, delay in seconds
    /// It uses native app lifecycle to trigger instead of
    /// flutter's lifecycle, because flutter lifecycle is not accurate
    /// when going into a natice viewController (eg: webview, pdfview, etc)
    /// The lockscreen only happens after onResume, android does not render
    /// in background
    this.autoLockAfterSeconds = -1,
  });

  final bool enableSecure;
  final int autoLockAfterSeconds;

  factory PrivacyAndroidOptions.disable() => const PrivacyAndroidOptions(
        enableSecure: false,
        autoLockAfterSeconds: -1,
      );
}

class PrivacyIosOptions {
  const PrivacyIosOptions({
    this.enablePrivacy = true,
    this.privacyImageName,
    this.autoLockAfterSeconds = -1,
    this.lockTrigger = IosLockTrigger.didEnterBackground,
  });

  /// Enable the privacy view when app goes into background
  final bool enablePrivacy;

  /// Enable auto lock, this is irrelevant with [enablePrivacy]
  /// You can disable [enablePrivacy] and still enable auto locker
  /// Disabled when <0, enable when >= 0, delay in seconds
  /// It uses native app lifecycle to trigger instead of
  /// flutter's lifecycle, because flutter lifecycle is not accurate
  /// when going into a natice viewController (eg: webview, pdfview, etc)
  final int autoLockAfterSeconds;

  /// This is the native image asset name in IOS
  /// To enable this feature, you will need
  /// to include [imageName] asset in the runner
  /// from xCode of you project and pass the
  /// [imageName] here such as "LaunchImage"
  /// Leave blank or null if you don't want to use a
  /// image in the privacyView
  final String? privacyImageName;

  /// You can choose between
  /// [IosLockTrigger.willResignActive] -> app entered app switcher
  /// - OR -
  /// [IosLockTrigger.didEnterBackground] -> app entered background (when switched to another app or home)
  final IosLockTrigger lockTrigger;

  factory PrivacyIosOptions.disable() => const PrivacyIosOptions(
        enablePrivacy: false,
        autoLockAfterSeconds: -1,
      );
}
