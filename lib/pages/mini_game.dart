import 'dart:async';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Ball {

  double x, y, radius, dx, dy;

  Ball({
    required this.x, 
    required this.y, 
    required this.radius, 
    required this.dx, 
    required this.dy
  });

  void updatePosition() {
    x += dx;
    y += dy;
  }
  
}

class PongPainter extends CustomPainter {
  
  final double paddlePosition;
  final Ball ball;

  PongPainter({required this.paddlePosition, required this.ball});

  @override
  void paint(Canvas canvas, Size size) {

    const paddleWidth = 155.0; 
    const paddleHeight = 15.0; 

    final paddleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paddlePosition,
        size.height - paddleHeight, 
        paddleWidth,
        paddleHeight,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      paddleRect,
      Paint()
        ..color = ThemeColor.darkBlack
        ..style = PaintingStyle.fill);

    canvas.drawCircle(
        Offset(ball.x, ball.y),
        ball.radius,
        Paint()
          ..color = ThemeColor.secondaryPurple
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class PongGame extends StatefulWidget {
  const PongGame({Key? key}) : super(key: key);

  @override
  State<PongGame> createState() => PongGameState();
}

class PongGameState extends State<PongGame> {
  
  late double paddlePosition;
  late Ball ball;

  final scoreNotifier = ValueNotifier<int>(0);
  final highScoreNotifier = ValueNotifier<int>(0);

  void checkCollisions() {

    if (ball.y + ball.radius >= MediaQuery.of(context).size.height - 90 && ball.x >= paddlePosition && ball.x <= paddlePosition + 155) {
      scoreNotifier.value++;
      highScoreNotifier.value++;
      ball.dy = -ball.dy;

    } else if (ball.y + ball.radius >= MediaQuery.of(context).size.height - 90) {
      resetBall();

    }

    if (ball.x - ball.radius <= 0 || ball.x + ball.radius >= MediaQuery.of(context).size.width) {
      ball.dx = -ball.dx;
    }

    if (ball.y - ball.radius <= 0) {
      ball.dy = -ball.dy;
    }

  }

  void resetBall() {
    ball.x = MediaQuery.of(context).size.width / 2;
    ball.y = MediaQuery.of(context).size.height / 2;
    ball.dx = 3;
    ball.dy = 3;
    scoreNotifier.value = scoreNotifier.value == 0 ? 0 : scoreNotifier.value-1;
  }

  void startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 8), (timer) {
      setState(() {
        ball.updatePosition();
        checkCollisions();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    paddlePosition = 0.0;
    ball = Ball(x: 150, y: 100, radius: 10, dx: 3, dy: 3);
    startGameLoop();
  }

  @override
  void dispose() {
    scoreNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.justWhite,
      appBar: CustomAppBar(
        backgroundColor: ThemeColor.justWhite,
        leadingColor: ThemeColor.darkBlack,
        context: context, 
        title: ""
      ).buildAppBar(),
      body: Center(
        child: Stack(
          children: [
            
            ValueListenableBuilder(
              valueListenable: highScoreNotifier,
              builder: (context, value, child) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Text("HIGH SCORE: ${value.toString()}", 
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: ThemeColor.thirdWhite,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
              },
            ),

            ValueListenableBuilder(
              valueListenable: scoreNotifier,
              builder: (context, value, child) {
                return Center(
                  child: Text(value.toString(), 
                    style: GoogleFonts.poppins(
                      fontSize: 135,
                      color: ThemeColor.thirdWhite,
                      fontWeight: FontWeight.bold
                    )
                  ),
                );
              },
            ),

            GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  paddlePosition += details.delta.dx;
                });
              },
              child: CustomPaint(
                painter: PongPainter(
                  paddlePosition: paddlePosition,
                  ball: ball,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height-90,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}