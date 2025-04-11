import Flutter
import UIKit

public class SwiftPrivacyScreenPlugin: NSObject, FlutterPlugin {
    
    var enablePrivacy = false
    var lockWithDidEnterBackground = true
    var privacyImageName: String?
    var backgroundOpacity: CGFloat = 1
    var backgroundColor: UIColor = UIColor.white
    var backgroundTask: UIBackgroundTaskIdentifier!
    var privacyUIView: UIView?
    var isInFadeIn: Bool = false
    let animationDuration: CFTimeInterval = 0.2
    var methodChannel: FlutterMethodChannel
    var timeEnteredBackground: Double = 0
    var autoLockAfterSeconds: Double = -1
    var blurEffect: UIBlurEffect.Style?
    var lockedDismissDelay: CFTimeInterval = 0.2
    
    
    internal let registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        methodChannel = FlutterMethodChannel(name: "channel.couver.privacy_screen", binaryMessenger: registrar.messenger())
        super.init()
        registrar.addApplicationDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftPrivacyScreenPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)
    }
    
    private func createPrivacyView() {
        
        if let window = UIApplication.shared.keyWindow {
            dismissPrivacyView()
            privacyUIView = UIView(frame: window.bounds);
            privacyUIView?.alpha = 0.0
            window.addSubview(privacyUIView!)
            
            if (blurEffect != nil && backgroundOpacity < 1) {
                
                let blurView = UIVisualEffectView(
                    effect: UIBlurEffect(
                        style: blurEffect!
                    )
                )
                blurView.frame = window.bounds
                
                privacyUIView!.addSubview(blurView)
            }
            
            if (backgroundOpacity > 0) {
                let opacityView = UIView(frame: window.bounds)
                opacityView.backgroundColor = backgroundColor
                opacityView.alpha = backgroundOpacity
                privacyUIView!.addSubview(opacityView)
            }
            
            if ( !(privacyImageName ?? "").isEmpty) {
                let logoView = UIImageView(image: UIImage(named: privacyImageName!))
                logoView.frame = window.bounds
                logoView.contentMode = .center
                privacyUIView!.addSubview(logoView)
            }
            
            isInFadeIn = true
            privacyUIView?.layer.removeAllAnimations()
            UIView.transition(with: privacyUIView!,
                              duration: animationDuration,
                              options: .transitionCrossDissolve,
                              animations: {
                self.privacyUIView?.alpha = 1.0
                self.isInFadeIn = false
                window.snapshotView(afterScreenUpdates: true)
            })
        }
    }
    
    private func dismissPrivacyView() {
            guard privacyUIView != nil else {
                return
            }
            privacyUIView?.layer.removeAllAnimations()
            UIView.transition(with: privacyUIView!,
                              duration: animationDuration,
                              options: .transitionCrossDissolve,
                              animations:  {
                self.privacyUIView?.alpha = 0.0
            }) { (finished) in
                if finished && self.privacyUIView != nil && self.isInFadeIn {
                    for subview in self.privacyUIView!.subviews { subview.removeFromSuperview() }
                    self.privacyUIView?.removeFromSuperview()
                    self.privacyUIView = nil
                }
            }
    }
    
    private func judgeLock() {
        let nowTime = NSDate().timeIntervalSince1970
        if(autoLockAfterSeconds >= 0 && timeEnteredBackground > 0 && (nowTime - timeEnteredBackground) > autoLockAfterSeconds) {
            methodChannel.invokeMethod("lock", arguments: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + lockedDismissDelay) {
                self.dismissPrivacyView()
            }
        } else {
            dismissPrivacyView()
        }
        timeEnteredBackground = 0
        
    }
    
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        methodChannel.invokeMethod("onLifeCycle", arguments: "applicationDidBecomeActive")
        judgeLock()
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        if(lockWithDidEnterBackground) {
            timeEnteredBackground = NSDate().timeIntervalSince1970
        }
        methodChannel.invokeMethod("onLifeCycle", arguments: "applicationDidEnterBackground")
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        methodChannel.invokeMethod("onLifeCycle", arguments: "applicationWillEnterForeground")
    }
    
    public func applicationWillResignActive(_ application: UIApplication) {
        if(!lockWithDidEnterBackground) {
            timeEnteredBackground = NSDate().timeIntervalSince1970
        }
        methodChannel.invokeMethod("onLifeCycle", arguments: "applicationWillResignActive")
        if ( enablePrivacy ) {
            self.registerBackgroundTask()
            UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
            createPrivacyView()
            self.endBackgroundTask()
        }
    }
    
    func registerBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(self.backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
            
        case "updateConfig":
            if let args = call.arguments as? Dictionary<String, Any> {
                if let backgroundOpacity = args["backgroundOpacity"] as? CGFloat {
                    self.backgroundOpacity = backgroundOpacity
                } else {
                    self.backgroundOpacity = 1
                }
                
                if let privacyImageName = args["privacyImageName"] as? String {
                    self.privacyImageName = privacyImageName
                } else {
                    self.privacyImageName = nil
                }
                
                if let backgroundColor = args["backgroundColor"] as? String {
                    self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
                } else {
                    self.backgroundColor = UIColor.white
                }
                
                if let blurEffect = args["blurEffect"] as? String {
                    switch blurEffect {
                    case "light":
                        self.blurEffect = UIBlurEffect.Style.light
                    case "dark":
                        self.blurEffect = UIBlurEffect.Style.dark
                    case "extraLight":
                        self.blurEffect = UIBlurEffect.Style.extraLight
                    default:
                        self.blurEffect = nil
                    }
                } else {
                    self.blurEffect = nil
                }
                
                if let enablePrivacyIos = args["enablePrivacyIos"] as? Bool {
                    self.enablePrivacy = enablePrivacyIos
                } else {
                    self.enablePrivacy = false
                }
                
                if let autoLockAfterSecondsIos = args["autoLockAfterSecondsIos"] as? Double {
                    self.autoLockAfterSeconds = autoLockAfterSecondsIos
                } else {
                    self.autoLockAfterSeconds = -1
                }
                
                if let lockWithDidEnterBackground = args["iosLockWithDidEnterBackground"] as? Bool {
                    self.lockWithDidEnterBackground = lockWithDidEnterBackground
                } else {
                    self.lockWithDidEnterBackground = true
                }
            }
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
