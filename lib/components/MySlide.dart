import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MySlide extends PageRouteBuilder {
  final Widget page;
  // Duration get transitionDuration => const Duration(milliseconds: 250);
  MySlide({this.page})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
}
