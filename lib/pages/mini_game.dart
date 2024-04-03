import 'dart:async';

import 'package:flutter/material.dart';

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
    // Draw paddles, ball, and game elements here
    // For example:
    canvas.drawRect(
        Rect.fromLTWH(paddlePosition, 180, 80, 10),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(ball.x, ball.y),
        ball.radius,
        Paint()
          ..color = Colors.red
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

  @override
  void initState() {
    super.initState();
    paddlePosition = 0.0;
    ball = Ball(x: 150, y: 100, radius: 10, dx: 3, dy: 3);
    startGameLoop();
  }

  void startGameLoop() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        ball.updatePosition();
        checkCollisions();
      });
    });
  }

  void checkCollisions() {
    // Check for collisions with walls
    if (ball.x - ball.radius <= 0 || ball.x + ball.radius >= 300) {
      ball.dx = -ball.dx; // Reverse horizontal velocity
    }
    if (ball.y - ball.radius <= 0 || ball.y + ball.radius >= 200) {
      ball.dy = -ball.dy; // Reverse vertical velocity
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: GestureDetector(
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
              child: const SizedBox(
                width: 300,
                height: 200,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
