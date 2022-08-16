import 'package:flutter/material.dart';
import 'package:privacy_screen/src/privacy_lock.dart';
import 'privacy_helpers.dart';
import 'privacy_screen.dart';

class PrivacyGate extends StatefulWidget {
  const PrivacyGate({
    Key? key,
    this.child,
    this.lockBuilder,
    this.navigatorKey,
    this.onLock,
    this.onUnlock,
    this.onLifeCycleChanged,
  }) : super(key: key);

  /// This is your main app
  final Widget? child;

  /// This is your lock
  final Widget Function(BuildContext context)? lockBuilder;

  /// Provide a global key with navigator (material) to use lock route,
  /// else stack will be used
  final GlobalKey<NavigatorState>? navigatorKey;

  /// When lock is triggered. You can skip lockBuilder and call your own method with onLock,
  /// Make sure you call instance's unlock if you handle you own onLock,
  /// otherwise the lock can't be reset correctly
  final VoidCallback? onLock;

  /// Call after unlock is triggered
  final VoidCallback? onUnlock;

  /// Called app's lifecycle is changed
  final ValueChanged<AppLifeCycle>? onLifeCycleChanged;

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _lockVisibilityCtrl;

  final Duration _animationDuration = const Duration(milliseconds: 300);

  double _blurRadius = 0;
  Color _blurColor = const Color(0xffffffff);
  PrivacyBlurEffect _blurEffect = PrivacyBlurEffect.none;
  Color _backgroundColor = const Color(0xffffffff);

  Route? _lockerRoute;

  @override
  void initState() {
    _lockVisibilityCtrl =
        AnimationController(vsync: this, duration: _animationDuration);
    super.initState();
    PrivacyScreen.instance.stateNotifier.addListener(_stateNotified);
    PrivacyScreen.instance.lockNotifier.addListener(_lockNotified);
    PrivacyScreen.instance.lifeCycleNotifier.addListener(_lifeCycleNotified);
  }

  @override
  void dispose() {
    PrivacyScreen.instance.stateNotifier.removeListener(_stateNotified);
    PrivacyScreen.instance.lockNotifier.removeListener(_lockNotified);
    PrivacyScreen.instance.lifeCycleNotifier.removeListener(_lifeCycleNotified);
    _lockVisibilityCtrl.dispose();
    super.dispose();
  }

  void _stateNotified() {
    bool hasChange = false;
    if (_blurEffect != PrivacyScreen.instance.blurEffect) {
      _blurEffect = PrivacyScreen.instance.blurEffect;
      _blurColor = _blurEffect.color;
      _blurRadius = _blurEffect.blurRadius;
      hasChange = true;
    }
    if (_backgroundColor != PrivacyScreen.instance.backgroundColor) {
      _backgroundColor = PrivacyScreen.instance.backgroundColor;
      hasChange = true;
    }
    if (hasChange) setState(() {});
  }

  void _lockNotified() {
    if (PrivacyScreen.instance.shouldLock) {
      _doLock();
    } else {
      _doUnlock();
    }
  }

  void _lifeCycleNotified() {
    widget.onLifeCycleChanged?.call(PrivacyScreen.instance.appLifeCycle);
  }

  Future _toLockPage() async {
    if (!(_lockerRoute?.isActive ?? false)) {
      _lockerRoute = PageRouteBuilder(
        pageBuilder: (ctx, _, __) => PrivacyLockWidget(
          blurColor: _blurColor,
          blurRadius: _blurRadius,
          backgroundColor: _backgroundColor,
          animation: _,
          lockBuilder: widget.lockBuilder,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: _animationDuration,
        fullscreenDialog: true,
        opaque: false,
      );
      return await widget.navigatorKey!.currentState?.push(_lockerRoute!);
    }
    return true;
  }

  void _doLock() {
    if (widget.lockBuilder != null) {
      if (widget.navigatorKey?.currentState != null) {
        print("_toLockPage");
        _toLockPage();
      } else {
        if (_lockVisibilityCtrl.value != 1) {
          _lockVisibilityCtrl.value = 1;
          setState(() {});
        }
      }
    }
    widget.onLock?.call();
  }

  void _doUnlock() async {
    if (widget.navigatorKey != null && (_lockerRoute?.isActive ?? false)) {
      if (_lockerRoute!.isCurrent) {
        widget.navigatorKey!.currentState?.pop();
      } else {
        widget.navigatorKey!.currentState?.removeRoute(_lockerRoute!);
      }
    }
    if (_lockVisibilityCtrl.value > 0) {
      await _lockVisibilityCtrl.animateBack(0).orCancel;
      setState(() {});
    }
    widget.onUnlock?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.navigatorKey?.currentState != null) {
      return widget.child ?? const SizedBox.shrink();
    }
    return Stack(
      children: [
        widget.child ?? const SizedBox.shrink(),
        // Use Overlay, otherwise input focus can not work

        if (_lockVisibilityCtrl.value > 0)
          Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => Positioned.fill(
                  child: PrivacyLockWidget(
                    backgroundColor: _backgroundColor,
                    animation: _lockVisibilityCtrl,
                    blurColor: _blurColor,
                    blurRadius: _blurRadius,
                    lockBuilder: widget.lockBuilder,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
