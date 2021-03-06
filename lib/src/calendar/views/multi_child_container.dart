part of calendar;

class _CalendarMultiChildContainer extends Stack {
  _CalendarMultiChildContainer(
      {this.painter, List<Widget> children, this.width, this.height})
      : super(children: children);
  final CustomPainter painter;
  final double width;
  final double height;

  @override
  RenderStack createRenderObject(BuildContext context) {
    final Directionality widget =
        context.dependOnInheritedWidgetOfExactType<Directionality>();
    return _MultiChildContainerRenderObject(width, height,
        painter: painter,
        direction: widget != null ? widget.textDirection : null);
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    super.updateRenderObject(context, renderObject);
    if (renderObject is _MultiChildContainerRenderObject) {
      final Directionality widget =
          context.dependOnInheritedWidgetOfExactType<Directionality>();
      renderObject
        ..width = width
        ..height = height
        ..painter = painter
        ..textDirection = widget != null ? widget.textDirection : null;
    }
  }
}

class _MultiChildContainerRenderObject extends RenderStack {
  _MultiChildContainerRenderObject(this._width, this._height,
      {CustomPainter painter, TextDirection direction})
      : _painter = painter,
        super(textDirection: direction);

  CustomPainter get painter => _painter;
  CustomPainter _painter;

  set painter(CustomPainter value) {
    if (_painter == value) {
      return;
    }

    final CustomPainter oldPainter = _painter;
    _painter = value;
    _updatePainter(_painter, oldPainter);
    if (attached) {
      oldPainter?.removeListener(markNeedsPaint);
      _painter?.addListener(markNeedsPaint);
    }
  }

  double get width => _width;

  set width(double value) {
    if (_width == value) {
      return;
    }

    _width = value;
    markNeedsLayout();
  }

  double _width;
  double _height;

  double get height => _height;

  set height(double value) {
    if (_height == value) {
      return;
    }

    _height = value;
    markNeedsLayout();
  }

  /// Caches [SemanticsNode]s created during [assembleSemanticsNode] so they
  /// can be re-used when [assembleSemanticsNode] is called again. This ensures
  /// stable ids for the [SemanticsNode]s of children across
  /// [assembleSemanticsNode] invocations.
  /// Ref: assembleSemanticsNode method in RenderParagraph class
  /// (https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/paragraph.dart)
  List<SemanticsNode> _cacheNodes;

  void _updatePainter(CustomPainter newPainter, CustomPainter oldPainter) {
    if (newPainter == null) {
      markNeedsPaint();
    } else if (oldPainter == null ||
        newPainter.runtimeType != oldPainter.runtimeType ||
        newPainter.shouldRepaint(oldPainter)) {
      markNeedsPaint();
    }

    if (newPainter == null) {
      if (attached) {
        markNeedsSemanticsUpdate();
      }
    } else if (oldPainter == null ||
        newPainter.runtimeType != oldPainter.runtimeType ||
        newPainter.shouldRebuildSemantics(oldPainter)) {
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _painter?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _painter?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void performLayout() {
    final Size widgetSize = constraints.biggest;
    size = Size(widgetSize.width.isInfinite ? width : widgetSize.width,
        widgetSize.height.isInfinite ? height : widgetSize.height);
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(constraints);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_painter != null) {
      _painter.paint(context.canvas, size);
    }

    paintStack(context, offset);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
  }

  @override
  void assembleSemanticsNode(
    SemanticsNode node,
    SemanticsConfiguration config,
    Iterable<SemanticsNode> children,
  ) {
    _cacheNodes ??= <SemanticsNode>[];
    final List<CustomPainterSemantics> semantics = semanticsBuilder(size);
    final List<SemanticsNode> semanticsNodes = <SemanticsNode>[];
    for (int i = 0; i < semantics.length; i++) {
      final CustomPainterSemantics currentSemantics = semantics[i];
      final SemanticsNode newChild = _cacheNodes.isNotEmpty
          ? _cacheNodes.removeAt(0)
          : SemanticsNode(key: currentSemantics.key);

      final SemanticsProperties properties = currentSemantics.properties;
      final SemanticsConfiguration config = SemanticsConfiguration();
      if (properties.label != null) {
        config.label = properties.label;
      }
      if (properties.textDirection != null) {
        config.textDirection = properties.textDirection;
      }

      newChild.updateWith(
        config: config,
        // As of now CustomPainter does not support multiple tree levels.
        childrenInInversePaintOrder: const <SemanticsNode>[],
      );

      newChild
        ..rect = currentSemantics.rect
        ..transform = currentSemantics.transform
        ..tags = currentSemantics.tags;

      semanticsNodes.add(newChild);
    }

    final List<SemanticsNode> finalChildren = <SemanticsNode>[];
    finalChildren.addAll(semanticsNodes);
    finalChildren.addAll(children);
    _cacheNodes = semanticsNodes;
    super.assembleSemanticsNode(node, config, finalChildren);
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
    _cacheNodes = null;
  }

  SemanticsBuilderCallback get semanticsBuilder {
    final List<CustomPainterSemantics> semantics = <CustomPainterSemantics>[];
    if (painter != null) {
      semantics.addAll(painter.semanticsBuilder(size));
    }
    for (RenderRepaintBoundary child = firstChild;
        child != null;
        child = childAfter(child)) {
      final _CustomCalendarRenderObject appointmentRenderObject = child.child;
      semantics.addAll(appointmentRenderObject.semanticsBuilder(size));
    }

    return (Size size) {
      return semantics;
    };
  }
}
