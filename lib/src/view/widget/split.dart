import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'dart:async';

/// {@template split_view_controller}
/// The controller of [SplitView]
/// It manages the navigation stack of the right pane.
/// {@endtemplate}
class SplitViewController {
  /// Notifier for the currently visible widget on the right pane
  late final VNode<List<Widget>> routes;

  /// Initializes the controller with the initial right widget.
  SplitViewController({Widget initialRight = UIs.placeholder}) {
    routes = [initialRight].vn;
  }

  /// Track the last operation direction for animation purposes
  bool _isPushing = true;

  /// Tracks whether an animation is currently in progress
  bool _isAnimating = false;

  /// AnimationController reference - will be set by SplitView widget
  AnimationController? _animationController;

  /// Sets the animation controller reference
  @protected
  void _setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  /// Pushes a new [page] onto the right view stack.
  /// Returns a Future that completes when the animation finishes.
  Future<bool> push(Widget page) async {
    // Don't allow operations during animation
    if (_isAnimating) return false;

    _isPushing = true;
    _isAnimating = true;

    // Update the stack in single operation to reduce rebuilds
    final newRoutes = List<Widget>.from(routes.value)..add(page);
    routes.value = newRoutes;

    // Wait for animation to complete
    if (_animationController != null) {
      await _runAnimation();
    }

    _isAnimating = false;
    return true;
  }

  /// Removes the top page from the right view stack, revealing the previous page.
  /// Does nothing if only the initial page is present.
  /// Returns a Future that completes when the animation finishes.
  Future<bool> pop() async {
    if (!canPop || _isAnimating) return false;

    _isPushing = false;
    _isAnimating = true;

    // Update the stack in single operation to reduce rebuilds
    final newRoutes = List<Widget>.from(routes.value)..removeLast();
    routes.value = newRoutes;

    // Wait for animation to complete
    if (_animationController != null) {
      await _runAnimation();
    }

    _isAnimating = false;
    return true;
  }

  /// Replaces the top page of the right view stack with a new page.
  /// Returns a Future that completes when the animation finishes.
  Future<bool> replace(Widget page) async {
    // Don't allow operations during animation
    if (_isAnimating) return false;
    
    // Need at least one route to replace
    if (routes.value.isEmpty) return false;

    // Compare the new page with the current top page by the key
    final lastPage = routes.value.last; // Routes not empty => lastPage not null
    if (lastPage.runtimeType == page.runtimeType) {
      return false; // No need to replace if the same type
    }
    if (lastPage.key != null && lastPage.key == page.key) {
      return false; // No need to replace if the same key
    }

    _isPushing = true; // We'll use the same animation as pushing
    _isAnimating = true;

    // Update the stack in single operation to reduce rebuilds
    final newRoutes = List<Widget>.from(routes.value);
    newRoutes[newRoutes.length - 1] = page;
    routes.value = newRoutes;

    // Wait for animation to complete
    if (_animationController != null) {
      await _runAnimation();
    }

    _isAnimating = false;
    return true;
  }

  /// Runs the animation sequence
  /// 
  /// Extracted to a separate method to avoid duplication
  Future<void> _runAnimation() async {
    _animationController!.reset();
    return _animationController!.forward().orCancel.catchError(
          (_) => Future<void>.value(),
          test: (error) => error is TickerCanceled,
        );
  }

  /// Returns true if the right view stack can be popped (i.e., contains more than one page).
  bool get canPop => routes.value.length > 1;

  /// Disposes the controller and its resources.
  void dispose() {
    routes.dispose();
  }
}

/// {@template split_view_scope}
/// InheritedWidget to provide SplitViewController down the tree
/// {@endtemplate}
class _SplitViewScope extends InheritedWidget {
  /// {@macro split_view_controller}
  final SplitViewController controller;

  /// {@macro split_view_scope}
  const _SplitViewScope({
    required this.controller,
    required super.child,
  });

  /// Finds the nearest [SplitViewController] ancestor in the widget tree.
  static SplitViewController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SplitViewScope>()?.controller;
  }

  @override
  bool updateShouldNotify(_SplitViewScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Provides navigation control for the right pane of a `SplitView`.
/// Similar to `Navigator`, but operates specifically on the `SplitView`'s right pane.
class SplitViewNavigator {
  /// Finds the nearest `SplitViewController` ancestor and returns it.
  /// Throws an error if no `SplitViewController` is found.
  static SplitViewController of(BuildContext context) {
    final controller = _SplitViewScope.of(context);
    assert(controller != null, 'SplitViewNavigator.of() called with a context that does not contain a SplitView.');
    return controller!;
  }

  /// Pushes a new [page] onto the right pane's navigation stack.
  /// Returns a Future that completes when the animation finishes.
  static Future<bool> push(BuildContext context, Widget page) {
    return of(context).push(page);
  }

  /// Pops the top page from the right pane's navigation stack.
  /// Returns a Future that completes when the animation finishes.
  static Future<bool> pop(BuildContext context) {
    return of(context).pop();
  }

  /// Replaces the top page of the right pane's navigation stack with a new page.
  /// Returns a Future that completes when the animation finishes.
  static Future<bool> replace(BuildContext context, Widget page) {
    return of(context).replace(page);
  }

  /// Checks if the right pane's navigation stack can be popped.
  static bool canPop(BuildContext context) {
    return of(context).canPop;
  }
}

/// {@template split_view}
/// A split view that allows for a split-screen layout with a left and right pane.
/// {@endtemplate}
class SplitView extends StatefulWidget {
  /// The controller for managing the split view's navigation.
  final SplitViewController? controller;

  /// A widget that provides a split view layout with a left and right pane.
  final AreaWidgetBuilder leftBuilder;

  /// The initial widget displayed on the right side of the split view.
  final Widget initialRight;

  /// The weight of the left pane in the split view.
  final double leftWeight;

  /// The weight of the right pane in the split view.
  final double rightWeight;

  /// The animation curve for the transition between pages.
  final Curve curve;

  /// The duration of the transition animation.
  final Duration duration;

  /// {@macro split_view}
  const SplitView({
    super.key,
    this.controller,
    required this.leftBuilder,
    required this.initialRight,
    this.leftWeight = 0.3,
    this.rightWeight = 0.7,
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.duration = Durations.medium3,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> with SingleTickerProviderStateMixin {
  late final controller = widget.controller ?? SplitViewController();
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  Widget? _previousWidget;
  Widget? _currentWidget;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Share animation controller with the SplitViewController
    controller._setAnimationController(_animationController);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    );

    // Initialize with initial right widget
    _currentWidget = controller.routes.value.lastOrNull ?? widget.initialRight;

    // Listen for route changes
    controller.routes.addListener(_handleRouteChange);
  }

  void _handleRouteChange() {
    _previousWidget = _currentWidget;
    _currentWidget = controller.routes.value.lastOrNull ?? widget.initialRight;
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.routes.removeListener(_handleRouteChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiSplitView = MultiSplitView(
      axis: Axis.horizontal,
      initialAreas: [
        _leftArea,
        _rightArea,
      ],
    );

    final theme = MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerPainter: DividerPainters.grooved1(
          color: UIs.bgColor.resolve(context),
          highlightedColor: UIs.primaryColor,
        ),
      ),
      child: multiSplitView,
    );

    // Provide the controller down the tree using _SplitViewScope
    return _SplitViewScope(
      controller: controller,
      child: theme,
    );
  }

  Area get _leftArea {
    return Area(
      flex: widget.leftWeight,
      // Pass the controller explicitly to the left builder as before
      builder: widget.leftBuilder,
    );
  }

  Area get _rightArea {
    return Area(
      flex: widget.rightWeight,
      builder: (context, area) => AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          // Get the current widget to display
          final rightWidget = controller.routes.value.lastOrNull ?? widget.initialRight;

          // Use a custom animation approach
          return Stack(
            children: [
              // Show previous widget with exit animation if exists and animation is running
              if (_previousWidget != null && controller._isPushing == false && _animationController.isAnimating)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(1.0, 0.0),
                  ).animate(_animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
                    child: KeyedSubtree(
                      key: ValueKey(_previousWidget),
                      child: _previousWidget!,
                    ),
                  ),
                ),

              // Show current widget with entrance animation
              SlideTransition(
                position: Tween<Offset>(
                  begin: _animationController.isAnimating && controller._isPushing
                      ? const Offset(1.0, 0.0)
                      : _animationController.isAnimating && !controller._isPushing
                          ? const Offset(-1.0, 0.0)
                          : Offset.zero,
                  end: Offset.zero,
                ).animate(_animation),
                child: FadeTransition(
                  opacity: Tween<double>(begin: _animationController.isAnimating ? 0.0 : 1.0, end: 1.0).animate(_animation),
                  child: KeyedSubtree(
                    key: ValueKey(rightWidget),
                    child: rightWidget,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
