import 'package:flutter/material.dart';

class PressLoadingIndicatorWidget extends StatefulWidget {
  final Color? color;
  final double size;

  const PressLoadingIndicatorWidget({super.key, this.color, this.size = 10});

  @override
  State<PressLoadingIndicatorWidget> createState() => _PressLoadingIndicatorWidgetState();
}

class _PressLoadingIndicatorWidgetState extends State<PressLoadingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _buildSquareRow(color),
    );
  }

  Widget _buildSquareRow(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => _buildSquare(index, color)),
    );
  }

  Widget _buildSquare(int index, Color color) {
    final opacity = _calculateOpacity(index);
    return Padding(
      padding: EdgeInsets.only(right: index < 2 ? widget.size * 0.6 : 0),
      child: Opacity(
        opacity: 0.25 + (opacity * 0.75),
        child: Container(
          width: widget.size,
          height: widget.size,
          color: color,
        ),
      ),
    );
  }

  double _calculateOpacity(int index) {
    final delay = index * 0.2;
    final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
    return t < 0.5 ? (t * 2) : (1 - (t - 0.5) * 2);
  }
}