import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/theme/colors.dart";
import "../../system_apps/cubit/system_apps_cubit.dart";
import "../../system_apps/views/system_apps_view.dart";
import "../cubit/search_cubit.dart";
import "../service/search_in_google_servic.dart";
import "widgets/contacts_list_view.dart";

class SearchView extends StatelessWidget {
  const SearchView({super.key, required this.cubit});
  final SystemAppsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(allApps: cubit.apps),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          final searchCubit = context.read<SearchCubit>();
          final query = state.searchQuery.toSearch;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: "ابحث في التطبيقات، الأسماء، أو جوجل...",
                  border: InputBorder.none,
                ),
                onChanged: (value) => searchCubit.search(value),
                onSubmitted: (value) async =>
                    await searchCubit.handleSubmitted(value, context),
              ),

              AppsListTile(apps: state.filteredApps, maxCount: 5, cubit: cubit),

              if (query.isNotEmpty && state.filteredContacts.isNotEmpty)
                ContactsListView(filteredContacts: state.filteredContacts),

              if (query.isNotEmpty)
                ListTile(
                  leading: Icon(LucideIcons.search, color: context.primary),
                  title: Text('البحث في جوجل عن "${state.searchQuery}"'),
                  onTap: () async => await searchInGoogleApp(state.searchQuery),
                ),
            ],
          );
        },
      ),
    );
  }
}
