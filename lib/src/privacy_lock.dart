import 'dart:ui';

import 'package:flutter/material.dart';

class PrivacyLockWidget extends StatefulWidget {
  const PrivacyLockWidget({
    Key? key,
    this.lockBuilder,
    required this.blurColor,
    required this.backgroundColor,
    required this.blurRadius,
    required this.animation,
  }) : super(key: key);

  // final Widget? child;
  final Color backgroundColor;
  final double blurRadius;
  final Color blurColor;
  final Animation<double> animation;
  final Widget Function(BuildContext context)? lockBuilder;

  @override
  State<PrivacyLockWidget> createState() => _PrivacyLockWidgetState();
}

class _PrivacyLockWidgetState extends State<PrivacyLockWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _blurBuilder({Widget? child}) {
    if (widget.blurRadius > 0) {
      return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: widget.blurRadius * (widget.animation.value),
            sigmaY: widget.blurRadius * (widget.animation.value)),
        child: Container(
          color: widget.blurColor,
          child: child,
        ),
      );
    } else {
      return child ?? const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (ctx, _) => _blurBuilder(
        child: Opacity(
          opacity: widget.animation.value,
          child: Material(
            color: widget.backgroundColor,
            child: widget.lockBuilder?.call(context),
          ),
        ),
      ),
    );
  }
}
