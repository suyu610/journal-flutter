import 'package:journal/components/bruno/src/components/selection/controller/brn_selection_view_controller.dart';
import 'package:flutter/material.dart';

/// 筛选动画展示隐藏组件
class BrnSelectionAnimationWidget extends StatefulWidget {
  /// 用于展示隐藏控制器
  final BrnSelectionListViewController controller;

  /// 子组件
  final Widget view;

  /// 动画时长
  final int animationMilliseconds;

  const BrnSelectionAnimationWidget({
    Key? key,
    required this.controller,
    required this.view,
    this.animationMilliseconds = 100,
  }) : super(key: key);

  @override
  _BrnSelectionAnimationWidgetState createState() =>
      _BrnSelectionAnimationWidgetState();
}

class _BrnSelectionAnimationWidgetState
    extends State<BrnSelectionAnimationWidget>
    with SingleTickerProviderStateMixin {
  bool _isControllerDisposed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.animationMilliseconds),
        vsync: this);
  }

  @override
  dispose() {
    widget.controller.removeListener(_onController);
    _animationController.dispose();
    _isControllerDisposed = true;
    super.dispose();
  }

  _onController() {
    _showListViewWidget();
  }

  @override
  Widget build(BuildContext context) {
    _animationController.duration =
        Duration(milliseconds: widget.animationMilliseconds);
    return _buildListViewWidget();
  }

  _showListViewWidget() {
    Animation<double> animation = Tween(
            begin: 0.0,
            end: MediaQuery.of(context).size.height -
                (widget.controller.listViewTop ?? 0))
        .animate(_animationController)
      ..addListener(() {
        //这行如果不写，没有动画效果
        setState(() {});
      });

    if (_isControllerDisposed) {
      return;
    }

    if (animation.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Widget _buildListViewWidget() {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      left: 0,
      child: Material(
        color: const Color(0xB3000000),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              (widget.controller.listViewTop ?? 0),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: widget.view,
          ),
        ),
      ),
    );
  }
}
