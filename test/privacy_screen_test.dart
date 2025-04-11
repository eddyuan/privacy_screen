// import 'package:flutter_test/flutter_test.dart';
// import 'package:privacy_screen/privacy_screen.dart';
// import 'package:privacy_screen/privacy_screen_platform_interface.dart';
// import 'package:privacy_screen/privacy_screen_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockPrivacyScreenPlatform
//     with MockPlatformInterfaceMixin
//     implements PrivacyScreenPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');

//   @override
//   Future enable() {
//     // TODO: implement enable
//     throw UnimplementedError();
//   }
// }

// void main() {
//   final PrivacyScreenPlatform initialPlatform = PrivacyScreenPlatform.instance;

//   test('$MethodChannelPrivacyScreen is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelPrivacyScreen>());
//   });

//   test('getPlatformVersion', () async {
//     PrivacyScreen privacyScreenPlugin = PrivacyScreen();
//     MockPrivacyScreenPlatform fakePlatform = MockPrivacyScreenPlatform();
//     PrivacyScreenPlatform.instance = fakePlatform;

//     expect(await privacyScreenPlugin.getPlatformVersion(), '42');
//   });
// }
