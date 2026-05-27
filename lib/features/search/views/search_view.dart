import "package:flutter/material.dart";

import "../../system_apps/cubit/system_apps_cubit.dart";
import "../../system_apps/models/application_model.dart";
import "../../system_apps/views/system_apps_view.dart";

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.cubit});
  final SystemAppsCubit cubit;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  SystemAppsCubit get cubit => widget.cubit;
  List<ApplicationModel> get allApps => cubit.apps;

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredApps = allApps.where((app) {
      final appName = app.appInfo.appName?.toLowerCase() ?? "";
      return appName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "أبحث...",
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        AppsListTile(apps: filteredApps, cubit: widget.cubit),
      ],
    );
  }
}
