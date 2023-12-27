class ShortenText {

  String cutText(String input, {int? customLength}) {

    int maxLength = customLength ?? 28;

    return input.length > maxLength 
    ? "${input.substring(0,maxLength)}..."
    : input;
    
  }

}