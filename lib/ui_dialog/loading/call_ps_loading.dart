import 'package:flowstorage_fsc/pages/public_storage/skeleton_loading_ps.dart';
import 'package:flutter/material.dart';

class CallPsLoading {

  final BuildContext context;
  
  CallPsLoading({required this.context});

  void stopLoading() {
    Navigator.pop(context);
  }

  void startLoading() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SkeletonLoadingPs();
        },
        reverseTransitionDuration: Duration.zero
      ),
    );
  }

}