import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: Home(),
    );
  }
}

class Tile extends StatefulWidget {
  final double w;
  final double h;
  final Color color;
  final bool autofocus;

  const Tile({
    Key key,
    this.w,
    this.h,
    this.color,
    this.autofocus,
  }) : super(key: key);

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
        autofocus: widget.autofocus ?? false,
        onFocusChange: (value) => setState(() {
          focused = value;
        }),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: focused ? Colors.pink : Colors.transparent,
            ),
            color: this.widget.color ?? Colors.grey[700],
          ),
          width: widget.w,
          height: widget.h,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FocusTraversalGroup(
        policy: AxisTraversalPolicy(axis: Axis.horizontal),
        child: Row(
          children: [
            Tile(w: 80, h: 30, color: Colors.blueGrey[600], autofocus: true),
            Tile(w: 80, h: 30, color: Colors.blueGrey[600]),
            Tile(w: 80, h: 30, color: Colors.blueGrey[600]),
            Tile(w: 80, h: 30, color: Colors.blueGrey[600]),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FocusTraversalGroup(
        policy: AxisTraversalPolicy(axis: Axis.vertical),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tile(w: 40, h: 40, color: Colors.blueGrey[700]),
            Tile(w: 40, h: 40, color: Colors.blueGrey[700]),
            Tile(w: 40, h: 40, color: Colors.blueGrey[700]),
            Tile(w: 40, h: 40, color: Colors.blueGrey[700]),
          ],
        ),
      ),
    );
  }
}

class Collection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: AxisTraversalPolicy(axis: Axis.horizontal),
      child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 76),
        itemBuilder: (context, index) {
          return Tile(w: 90);
        },
      ),
    );
  }
}

class AxisTraversalPolicy extends FocusTraversalPolicy {
  final Axis axis;

  AxisTraversalPolicy({this.axis});

  @override
  FocusNode findFirstFocusInDirection(
    FocusNode currentNode,
    TraversalDirection direction,
  ) {
    return null;
  }

  @override
  FocusNode findFirstFocus(FocusNode fn) {
    return null;
  }

  bool handleHorizontalGroupNavigation(
    FocusNode currentNode,
    TraversalDirection direction,
    Iterable<FocusNode> nodes,
  ) {
    switch (direction) {
      case TraversalDirection.left:
        if (nodes.first == currentNode) {
          exitGroup(currentNode, direction);
        } else {
          moveFocus(currentNode, direction);
        }
        break;

      case TraversalDirection.right:
        if (nodes.last == currentNode) {
          exitGroup(currentNode, direction);
        } else {
          moveFocus(currentNode, direction);
        }
        break;
      case TraversalDirection.up:
      case TraversalDirection.down:
        exitGroup(currentNode, direction);
        break;
    }

    return true;
  }

  bool handleVerticalGroupNavigation(
    FocusNode currentNode,
    TraversalDirection direction,
    Iterable<FocusNode> nodes,
  ) {
    switch (direction) {
      case TraversalDirection.up:
        if (nodes.first == currentNode) {
          exitGroup(currentNode, direction);
        } else {
          moveFocus(currentNode, direction);
        }
        break;

      case TraversalDirection.down:
        if (nodes.last == currentNode) {
          exitGroup(currentNode, direction);
        } else {
          moveFocus(currentNode, direction);
        }
        break;
      case TraversalDirection.left:
      case TraversalDirection.right:
        exitGroup(currentNode, direction);
        break;
    }

    return true;
  }

  void exitGroup(FocusNode node, TraversalDirection direction) {
    var candidates = node.nearestScope.traversalDescendants.toList();
    final newNode = _moveFocus(node, direction, candidates);

    Scrollable.ensureVisible(
      newNode.context,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      duration: const Duration(milliseconds: 250),
    );
  }

  void moveFocus(FocusNode node, TraversalDirection direction) {
    var candidates = node.parent.traversalDescendants
        .where((element) => element != node)
        .toList();

    final newNode = _moveFocus(node, direction, candidates);

    Scrollable.ensureVisible(
      newNode.context,
      alignment: 0.5,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      duration: const Duration(milliseconds: 250),
    );
  }

  FocusNode _moveFocus(FocusNode node, TraversalDirection direction,
      List<FocusNode> candidates) {
    switch (direction) {
      case TraversalDirection.up:
        candidates = candidates
            .where((element) => element.rect.bottom < node.rect.top)
            .toList();
        break;
      case TraversalDirection.right:
        candidates = candidates
            .where((element) => element.rect.left > node.rect.right)
            .toList();
        break;
      case TraversalDirection.down:
        candidates = candidates
            .where((element) => element.rect.top > node.rect.bottom)
            .toList();
        break;
      case TraversalDirection.left:
        candidates = candidates
            .where((element) => element.rect.right < node.rect.left)
            .toList();
        break;
    }

    if (candidates.isEmpty) return node;

    candidates
      ..sort((a, b) {
        switch (direction) {
          case TraversalDirection.up:
            return (node.rect.topCenter - a.rect.bottomCenter)
                .distance
                .compareTo(
                    (node.rect.topCenter - b.rect.bottomCenter).distance);

          case TraversalDirection.right:
            return (node.rect.centerRight - a.rect.centerLeft)
                .distance
                .compareTo(
                    (node.rect.centerRight - b.rect.centerLeft).distance);
          case TraversalDirection.down:
            return (node.rect.bottomCenter - a.rect.topCenter)
                .distance
                .compareTo(
                    (node.rect.bottomCenter - b.rect.topCenter).distance);
          case TraversalDirection.left:
            return (node.rect.centerRight - a.rect.centerLeft)
                .distance
                .compareTo(
                    (node.rect.centerRight - b.rect.centerLeft).distance);
        }

        return 0;
      });

    final newFocusNode = candidates.first;
    newFocusNode.requestFocus();
    return newFocusNode;
  }

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    var items = sortDescendants(currentNode.parent.children);

    if (axis == Axis.vertical) {
      handleVerticalGroupNavigation(currentNode, direction, items);
    } else {
      handleHorizontalGroupNavigation(currentNode, direction, items);
    }

    return false;
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants) {
    int Function(FocusNode, FocusNode) compare;

    switch (axis) {
      case Axis.horizontal:
        compare = (a, b) => (a.offset.dx - b.offset.dx).toInt();
        break;
      case Axis.vertical:
        compare = (a, b) => (a.offset.dy - b.offset.dy).toInt();
        break;
    }

    return descendants.toList()..sort(compare);
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: ListView.builder(
              itemCount: 8,
              padding: const EdgeInsets.only(top: 100),
              itemBuilder: (context, index) {
                return Container(
                  height: 160,
                  child: Collection(),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 68.0),
              child: TopBar(),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Sidebar(),
          ),
        ],
      ),
    );
  }
}
