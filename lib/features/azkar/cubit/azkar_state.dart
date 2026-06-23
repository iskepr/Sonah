import "../data/azkar_data.dart";

abstract class AzkarState {}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final Azkar azkar;
  final Map<int, int> currentCounts;

  AzkarLoaded({required this.azkar, required this.currentCounts});
}

class AzkarFinished extends AzkarState {}
