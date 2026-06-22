import "package:flutter_contacts/flutter_contacts.dart";

import "../../../core/extensions/extensions.dart";
import "../../system_apps/models/application_model.dart";

class SearchUtils {
  static List<ApplicationModel> getSmartSuggestions(
    List<ApplicationModel> allApps,
  ) {
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

    final List<ApplicationModel> suggestions = [];
    int index = 0;

    while (suggestions.length < 5 &&
        (index < mostOpened.length ||
            index < recentlyOpened.length ||
            index < newlyInstalled.length)) {
      if (index < mostOpened.length) {
        _addUniqueApp(suggestions, mostOpened[index]);
      }
      if (suggestions.length < 5 && index < recentlyOpened.length) {
        _addUniqueApp(suggestions, recentlyOpened[index]);
      }
      if (suggestions.length < 5 && index < newlyInstalled.length) {
        _addUniqueApp(suggestions, newlyInstalled[index]);
      }
      index++;
    }

    for (var app in visibleApps) {
      if (suggestions.length >= 5) break;
      _addUniqueApp(suggestions, app);
    }

    return suggestions;
  }

  static void _addUniqueApp(List<ApplicationModel> list, ApplicationModel app) {
    if (!list.any(
      (element) => element.appInfo.packageName == app.appInfo.packageName,
    )) {
      list.add(app);
    }
  }

  /// 2. فلترة وترتيب التطبيقات بناءً على نص البحث
  static List<ApplicationModel> filterApps(
    List<ApplicationModel> allApps,
    String query,
  ) {
    final filtered = allApps
        .where((app) => app.appInfo.appName.toSearch.contains(query))
        .toList();

    return filtered..sort((a, b) {
      final aStartsWith = a.appInfo.appName.toSearch.startsWith(query);
      final bStartsWith = b.appInfo.appName.toSearch.startsWith(query);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return b.openCount.compareTo(
        a.openCount,
      ); // الأولوية للأكثر فتحاً لو يتشابه البداية
    });
  }

  /// 3. فلترة جهات الاتصال بجميع الشروط
  static List<Contact> filterContacts(List<Contact> allContacts, String query) {
    return allContacts.where((contact) {
      if (contact.displayName.toSearch.contains(query)) return true;
      if (contact.phones.any((p) => p.number.toSearch.contains(query))) {
        return true;
      }
      if (contact.emails.any((e) => e.address.toSearch.contains(query))) {
        return true;
      }
      if (contact.notes.any((n) => n.note.toSearch.contains(query))) {
        return true;
      }
      if (contact.addresses.any((a) => a.formatted.toSearch.contains(query))) {
        return true;
      }
      return contact.organizations.any(
        (org) =>
            org.name.toSearch.contains(query) ||
            org.jobTitle.toSearch.contains(query),
      );
    }).toList();
  }
}
