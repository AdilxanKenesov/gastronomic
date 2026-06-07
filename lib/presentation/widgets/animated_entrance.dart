import 'package:flutter/material.dart';

/// Bola elementni bir marta "kirish" animatsiyasi bilan ko'rsatadi:
/// element o'ngdan suzib kirib keladi (o'ngdan chapga) va asta-sekin paydo
/// bo'ladi (fade-in). Intro ekranidan keyingi UI elementlarini bosqichma-bosqich
/// (staggered) ochib berish uchun ishlatiladi.
class AnimatedEntrance extends StatefulWidget {
  final Widget child;

  /// Animatsiya boshlanishidan oldingi kechikish — bir nechta elementni
  /// bosqichma-bosqich (staggered) chiqarish uchun.
  final Duration delay;

  /// Animatsiya davomiyligi.
  final Duration duration;

  /// O'ngdan suzib kirish masofasi (ekran kengligiga nisbatan ulush).
  final double slide;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.slide = 0.22,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            // (1 - t) → boshida o'ngda, oxirida joyida (0).
            offset: Offset((1 - t) * widget.slide * width, 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
