import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../constant.dart";
import "../../../core/extensions/extensions.dart";
import "../../../core/theme/colors.dart";
import "../../system_apps/cubit/system_apps_cubit.dart";
import "../../system_apps/views/system_apps_view.dart";
import "../cubit/search_cubit.dart";
import "../service/search_in_google_servic.dart";
import "widgets/contacts_list_view.dart";

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final query = state.searchQuery.toSearch;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppsListTile(
              apps: state.filteredApps,
              maxCount: 5,
              cubit: context.read<SystemAppsCubit>(),
            ),

            if (query.isNotEmpty && state.filteredContacts.isNotEmpty)
              ContactsListView(filteredContacts: state.filteredContacts),

            if (query.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: kSmallPadding * 2,
                  ),
                  child: Icon(LucideIcons.search, color: context.primary),
                ),
                title: Text('البحث في جوجل عن "${state.searchQuery}"'),
                onTap: () async => await searchInGoogleApp(state.searchQuery),
              ),
          ],
        );
      },
    );
  }
}
