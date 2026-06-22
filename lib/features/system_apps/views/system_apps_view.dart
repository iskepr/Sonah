import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../cubit/system_apps_cubit.dart";
import "widgets/apps_list_tile.dart";

class AppsListView extends StatelessWidget {
  const AppsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemAppsCubit, SystemAppsState>(
      builder: (context, state) {
        if (state is! SystemAppsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final apps = state.apps
            .where((app) => app.isFavorite && !app.isHidden)
            .toList();
        return AppsListTile(apps: apps, cubit: context.read<SystemAppsCubit>());
      },
    );
  }
}
