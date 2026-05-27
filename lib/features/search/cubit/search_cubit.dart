import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_contacts/flutter_contacts.dart";
import "package:flutter_device_apps/flutter_device_apps.dart";

import "../../../core/extensions/extensions.dart";
import "../../system_apps/models/application_model.dart";
import "../service/search_in_google_servic.dart";
import "../service/start_call_service.dart";

part "search_state.dart";

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.allApps}) : super(const SearchState()) {
    _loadContacts();
    search("");
  }

  final List<ApplicationModel> allApps;

  Future<void> _loadContacts() async {
    emit(state.copyWith(isContactsLoading: true));

    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (status == PermissionStatus.granted) {
      final List<Contact> contacts = await FlutterContacts.getAll(
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
    if (value.trim().isEmpty) {
      final visibleApps = allApps.where((app) => !app.isHidden).toList();

      final mostOpened =
          [...visibleApps].where((app) => app.openCount > 0).toList()
            ..sort((a, b) => b.openCount.compareTo(a.openCount));

      final recentlyOpened =
          [...visibleApps].where((app) => app.lastOpenTime != null).toList()
            ..sort((a, b) => b.lastOpenTime!.compareTo(a.lastOpenTime!));

      final newlyInstalled =
          [
            ...visibleApps,
          ].where((app) => app.appInfo.firstInstallTime != null).toList()..sort(
            (a, b) => b.appInfo.firstInstallTime!.compareTo(
              a.appInfo.firstInstallTime!,
            ),
          );

      final List<ApplicationModel> smartSuggestions = [];

      int index = 0;
      while (smartSuggestions.length < 5 &&
          (index < mostOpened.length ||
              index < recentlyOpened.length ||
              index < newlyInstalled.length)) {
        // لقطة من الأكثر فتحاً
        if (index < mostOpened.length) {
          final app = mostOpened[index];
          if (!smartSuggestions.any(
            (element) => element.appInfo.packageName == app.appInfo.packageName,
          )) {
            smartSuggestions.add(app);
          }
        }

        // لو لسه محتاجين، ناخد لقطة من المفتوحة مؤخراً
        if (smartSuggestions.length < 5 && index < recentlyOpened.length) {
          final app = recentlyOpened[index];
          if (!smartSuggestions.any(
            (element) => element.appInfo.packageName == app.appInfo.packageName,
          )) {
            smartSuggestions.add(app);
          }
        }

        // لو لسه محتاجين، ناخد لقطة من المثبتة حديثاً
        if (smartSuggestions.length < 5 && index < newlyInstalled.length) {
          final app = newlyInstalled[index];
          if (!smartSuggestions.any(
            (element) => element.appInfo.packageName == app.appInfo.packageName,
          )) {
            smartSuggestions.add(app);
          }
        }

        index++;
      }

      if (smartSuggestions.length < 5) {
        for (var app in visibleApps) {
          if (smartSuggestions.length >= 5) break;
          if (!smartSuggestions.any(
            (element) => element.appInfo.packageName == app.appInfo.packageName,
          )) {
            smartSuggestions.add(app);
          }
        }
      }

      emit(
        state.copyWith(
          searchQuery: value,
          filteredApps: smartSuggestions,
          filteredContacts: const [],
        ),
      );
      return;
    }

    final query = value.toSearch;

    final filteredApps = allApps.where((app) {
      return app.appInfo.appName.toSearch.contains(query);
    }).toList();

    final filteredContacts = state.allContacts.where((Contact contact) {
      if (contact.displayName.toSearch.contains(query)) return true;

      if (contact.phones.any(
        (phone) => phone.number.toSearch.contains(query),
      )) {
        return true;
      }

      if (contact.emails.any(
        (email) => email.address.toSearch.contains(query),
      )) {
        return true;
      }

      if (contact.organizations.any((org) {
        return org.name.toSearch.contains(query) ||
            org.jobTitle.toSearch.contains(query);
      })) {
        return true;
      }

      if (contact.addresses.any(
        (addr) => addr.formatted.toSearch.contains(query),
      )) {
        return true;
      }

      return false;
    }).toList();

    emit(
      state.copyWith(
        searchQuery: value,
        filteredApps: filteredApps,
        filteredContacts: filteredContacts,
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
}
