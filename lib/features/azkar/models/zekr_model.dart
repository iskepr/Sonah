import "package:adhan/adhan.dart";

class Zekr {
  final int count;
  final String? description;
  final String? reference;
  final String content;
  final List<Prayer>? prayers;

  Zekr({
    required this.count,
    this.description,
    this.reference,
    required this.content,
    this.prayers,
  });
}