import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {

  final Widget? child;

  const SplashWidget({
    required this.child,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: child
      ),
    );
  }

}