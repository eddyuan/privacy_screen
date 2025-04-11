#import "PrivacyScreenPlugin.h"
#if __has_include(<privacy_screen/privacy_screen-Swift.h>)
#import <privacy_screen/privacy_screen-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "privacy_screen-Swift.h"
#endif

@implementation PrivacyScreenPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPrivacyScreenPlugin registerWithRegistrar:registrar];
}
@end
