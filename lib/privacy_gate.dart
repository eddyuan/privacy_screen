import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacy_screen/privacy_screen.dart';

class PrivacyGate extends StatefulWidget {
  const PrivacyGate({
    Key? key,
    required this.child,
    this.lockBuilder,
  }) : super(key: key);

  final Widget child;
  final Widget Function(BuildContext context)? lockBuilder;

  @override
  State<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<PrivacyGate>
    with SingleTickerProviderStateMixin {
  bool _isLocked = PrivacyScreen.instance.shouldLock;

  late AnimationController _lockVisibilityCtrl;

  double _blurRadius = 0;
  Color _blurColor = const Color(0xffffffff);
  PrivacyBlurEffect _blurEffect = PrivacyBlurEffect.none;
  Color _backgroundColor = const Color(0xffffffff);

  @override
  void initState() {
    _lockVisibilityCtrl =
        AnimationController(vsync: this, duration: kThemeAnimationDuration * 2)
          ..addListener(_handleChange);
    super.initState();
    PrivacyScreen.instance.addListener(_privacyNotified);
    // _channel.setMethodCallHandler(methodCallHandler);
  }

  @override
  void dispose() {
    PrivacyScreen.instance.removeListener(_privacyNotified);
    _lockVisibilityCtrl.dispose();
    super.dispose();
  }

  void _privacyNotified() {
    bool hasChange = false;
    if (_isLocked != PrivacyScreen.instance.shouldLock) {
      _isLocked = PrivacyScreen.instance.shouldLock;
      if (_isLocked) {
        _lockVisibilityCtrl.value = 1;
      } else {
        _lockVisibilityCtrl.animateBack(0).orCancel;
      }
      hasChange = true;
    }
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
    if (hasChange) {
      setState(() {
        // The listenable's state is our build state, and it changed already.
      });
    }
  }

  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  Widget _blurBuilder({Widget? child}) {
    if (_blurRadius > 0) {
      return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: _blurRadius * _lockVisibilityCtrl.value,
            sigmaY: _blurRadius * _lockVisibilityCtrl.value),
        child: Container(
          color: _blurColor,
          child: child,
        ),
      );
    } else {
      return child ?? const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: false,
          child: widget.child,
        ),
        if (_lockVisibilityCtrl.value > 0)
          Positioned.fill(
            child: _blurBuilder(
              child: Opacity(
                opacity: _lockVisibilityCtrl.value,
                child: Container(
                  color: _backgroundColor,
                  child: widget.lockBuilder?.call(context),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
