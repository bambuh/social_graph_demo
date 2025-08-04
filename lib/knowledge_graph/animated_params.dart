import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class AnimatedParams extends ChangeNotifier {
  AnimatedParams({required TickerProvider vsync}) : _vsync = vsync;

  @override
  void dispose() {
    super.dispose();
    for (final animation in _animations.values) {
      animation.dispose();
    }
    _animations.clear();
  }

  double? get(String key) => _params[key];

  void set(String key, double value) {
    _params[key] = value;
    notifyListeners();
  }

  void addAnimation(
    String key, {
    required double from,
    required double to,
    required Duration duration,
    Curve curve = Curves.linear,
    void Function()? onComplete,
  }) {
    if (_animations.containsKey(key)) {
      _animations[key]!.dispose();
    }
    final animationController = AnimationController(
      duration: duration,
      vsync: _vsync,
    )..forward();
    final animation = Tween<double>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(parent: animationController, curve: curve));
    animation.addListener(() {
      set(key, animation.value);
      if (animation.isCompleted) {
        _animations.remove(key);
        onComplete?.call();
        animationController.dispose();
      }
    });
    _animations[key] = animationController;
  }

  final Map<String, double> _params = {};
  final Map<String, AnimationController> _animations = {};
  final TickerProvider _vsync;
}
