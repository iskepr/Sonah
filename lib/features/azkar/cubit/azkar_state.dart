abstract class AzkarState {}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  final List<dynamic> azkarList;
  final Map<int, int> currentCounts;
  final String title;

  AzkarLoaded({
    required this.azkarList,
    required this.currentCounts,
    required this.title,
  });
}

class AzkarFinished extends AzkarState {}
