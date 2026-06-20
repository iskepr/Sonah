import "../models/application_model.dart";

class SystemAppsState {}

class SystemAppsInitial extends SystemAppsState {}

class SystemAppsLoading extends SystemAppsState {}

class SystemAppsLoaded extends SystemAppsState {
  final List<ApplicationModel> apps;
  final int appsCount;
  SystemAppsLoaded({required this.apps, required this.appsCount});
}