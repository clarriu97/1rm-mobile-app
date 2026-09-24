import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A [ListView] whose children fade and rise in one after another the first
/// time it appears. Children added later, and everything when the system asks
/// for reduced motion, appear at once.
class StaggeredList extends StatefulWidget {
  const StaggeredList({super.key, this.padding, required this.children});

  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  /// Only the first items are staggered, so the last one starts in time.
  static const int maxStaggered = 8;

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.long,
  );

  static const _step = 0.06;
  static const _itemLength = 0.5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.isDismissed) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: widget.padding,
      children: [
        for (final (index, child) in widget.children.indexed)
          _Entrance(
            // Keyed like the child, so reordered items keep their state.
            key: child.key == null ? null : ValueKey(child.key),
            animation: _controller.drive(
              CurveTween(
                curve: Interval(
                  index.clamp(0, StaggeredList.maxStaggered) * _step,
                  index.clamp(0, StaggeredList.maxStaggered) * _step +
                      _itemLength,
                  curve: AppMotion.curve,
                ),
              ),
            ),
            child: child,
          ),
      ],
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.15), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
