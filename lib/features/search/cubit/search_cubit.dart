import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_contacts/flutter_contacts.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/utils/platform_utils.dart";
import "../../system_apps/cubit/system_apps_cubit.dart";
import "../../system_apps/models/application_model.dart";
import "../service/search_in_google_servic.dart";
import "../service/start_call_service.dart";
import "../utils/search_utils.dart";

part "search_state.dart";

class SearchCubit extends Cubit<SearchState> {
  final SystemAppsCubit systemAppsCubit;
  StreamSubscription? _appsSubscription;
  List<ApplicationModel> allApps = [];

  SearchCubit({required this.systemAppsCubit}) : super(const SearchState()) {
    _loadContacts();
    _listenToSystemApps();
  }

  void _listenToSystemApps() {
    if (systemAppsCubit.state is SystemAppsLoaded) {
      allApps = (systemAppsCubit.state as SystemAppsLoaded).apps;
      search(state.searchQuery);
    }

    _appsSubscription = systemAppsCubit.stream.listen((appsState) {
      if (appsState is SystemAppsLoaded) {
        allApps = appsState.apps;
        search(state.searchQuery);
      }
    });
  }

  Future<void> _loadContacts() async {
    if (!PlatformUtils.isAndroid) return;

    emit(state.copyWith(isContactsLoading: true));
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (status == PermissionStatus.granted) {
      final contacts = await FlutterContacts.getAll(
        properties: ContactProperties.all,
      );
      final validContacts = contacts.where((c) => c.phones.isNotEmpty).toList();

      emit(
        state.copyWith(allContacts: validContacts, isContactsLoading: false),
      );
      if (state.searchQuery.isNotEmpty) search(state.searchQuery);
    } else {
      emit(state.copyWith(isContactsLoading: false));
    }
  }

  void search(String value) {
    final cleanedValue = value.trim();

    // حالة البحث الفاضي (اقتراحات ذكية)
    if (cleanedValue.isEmpty) {
      emit(
        state.copyWith(
          searchQuery: value,
          filteredApps: SearchUtils.getSmartSuggestions(allApps),
          filteredContacts: const [],
        ),
      );
      return;
    }

    // حالة البحث الفعلي بكلمة معينة
    final query = cleanedValue.toSearch;
    emit(
      state.copyWith(
        searchQuery: value,
        filteredApps: SearchUtils.filterApps(allApps, query),
        filteredContacts: SearchUtils.filterContacts(state.allContacts, query),
      ),
    );
  }

  Future<void> handleSubmitted(String value, BuildContext context) async {
    if (state.filteredApps.isNotEmpty &&
        state.filteredApps.first.appInfo.packageName != null) {
      await FlutterDeviceApps.openApp(
        state.filteredApps.first.appInfo.packageName!,
      );
    } else if (state.filteredContacts.isNotEmpty) {
      await startCall(state.filteredContacts.first, context: context);
    } else {
      await searchInGoogleApp(value);
    }
  }

  @override
  Future<void> close() async {
    await _appsSubscription?.cancel();
    return super.close();
  }
}
