import 'dart:math';

class Generator {

  static String generateRandomString(int length) {

    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
    ));

  }

  static int generateRandomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }
  
}