import 'dart:async';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/services/swipe_hint_service.dart';

class SwipeConfirmWidget extends StatefulWidget {
  final Widget child;
  final Future<bool> Function() onConfirm;
  final double resistance;
  final double thresholdFraction;
  final Color? thresholdLineColor;
  final bool showHint;

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;

  const SwipeConfirmWidget({
    super.key,
    required this.child,
    required this.onConfirm,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    this.resistance = 0.71,
    this.thresholdFraction = 0.35,
    this.thresholdLineColor,
    this.showHint = false,
  });

  @override
  State<SwipeConfirmWidget> createState() => _SwipeConfirmWidgetState();
}

class _SwipeConfirmWidgetState extends State<SwipeConfirmWidget> with SingleTickerProviderStateMixin {
  static const double _hintDistance = 60;
  static const Duration _hintRepeatInterval = Duration(seconds: 6);

  double _drag = 0;
  late final AnimationController _bounceController;
  bool _isAskingConfirmation = false;
  bool _isUserDragging = false;
  bool _hasMarkedDiscovered = false;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    if (widget.showHint) _startHintLoopIfNeeded();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  // ---------- Hint repetido ----------

  Future<void> _startHintLoopIfNeeded() async {
    final alreadySeen = await SwipeHintService().hasSeenHint();
    if (alreadySeen || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    final stillNotSeen = !(await SwipeHintService().hasSeenHint());
    if (!mounted || !stillNotSeen) return;

    _playPeekAnimation();
    _hintTimer = Timer.periodic(_hintRepeatInterval, (_) => _onHintTick());
  }

  void _onHintTick() async {
    if (!mounted || _isUserDragging || _isAskingConfirmation) return;

    final alreadySeen = await SwipeHintService().hasSeenHint();
    if (alreadySeen) {
      _hintTimer?.cancel();
      return;
    }
    _playPeekAnimation();
  }

  Future<void> _playPeekAnimation() async {
    if (!mounted || _hasMarkedDiscovered || _isUserDragging) return;

    final peekOut = Tween<double>(begin: 0, end: -_hintDistance).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );
    peekOut.addListener(() {
      if (mounted) setState(() => _drag = peekOut.value);
    });
    await _bounceController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _snapBack();
  }

  void _markAsDiscovered() {
    if (_hasMarkedDiscovered) return;
    _hasMarkedDiscovered = true;
    _hintTimer?.cancel();
    SwipeHintService().markHintAsSeen();
  }

  // ---------- Arrastre real del usuario ----------

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAskingConfirmation) return;
    _isUserDragging = true;
    _markAsDiscovered();
    setState(() {
      _drag += details.delta.dx * widget.resistance;
      _drag = _drag.clamp(-double.infinity, 0);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details, double threshold) async {
    _isUserDragging = false;
    if (_drag.abs() > threshold) {
      setState(() => _isAskingConfirmation = true);
      await widget.onConfirm();
      _isAskingConfirmation = false;
    }
    _snapBack();
  }

  void _snapBack() {
    final animation = Tween<double>(begin: _drag, end: 0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );
    animation.addListener(() {
      if (mounted) setState(() => _drag = animation.value.clamp(-double.infinity, 0));
    });
    _bounceController.forward(from: 0);
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildWithConstraints);
  }

  Widget _buildWithConstraints(BuildContext context, BoxConstraints constraints) {
    final threshold = constraints.maxWidth * widget.thresholdFraction;
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: (details) => _onDragEnd(details, threshold),
      child: Stack(
        children: [
          _buildBackgroundLayer(threshold),
          _buildDraggableChild(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundLayer(double threshold) {
    final lineColor = widget.thresholdLineColor ?? widget.foregroundColor.withValues(alpha: 0.5);
    return Positioned.fill(
      child: Stack(
        children: [
          _buildBackground(threshold),
          _buildThresholdLine(threshold, lineColor),
        ],
      ),
    );
  }

  Widget _buildThresholdLine(double threshold, Color lineColor) {
    return Positioned(
      right: threshold,
      top: 0,
      bottom: 0,
      child: CustomPaint(
        size: const Size(1, double.infinity),
        painter: _DashedLinePainter(color: lineColor),
      ),
    );
  }

  Widget _buildDraggableChild(BuildContext context) {
    return Transform.translate(
      offset: Offset(_drag, 0),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: widget.child,
      ),
    );
  }

  Widget _buildBackground(double threshold) {
    return Container(
      alignment: Alignment.centerRight,
      color: widget.backgroundColor,
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            width: threshold,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.foregroundColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(widget.icon, size: 16, color: widget.foregroundColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dashHeight = 4.0;
    const dashGap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}