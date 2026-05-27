part of "search_cubit.dart";

class SearchState {
  final String searchQuery;
  final List<Contact> allContacts;
  final List<ApplicationModel> filteredApps;
  final List<Contact> filteredContacts;
  final bool isContactsLoading;

  const SearchState({
    this.searchQuery = "",
    this.allContacts = const [],
    this.filteredApps = const [],
    this.filteredContacts = const [],
    this.isContactsLoading = false,
  });

  // دالة الـ copyWith عشان نحدث أجزاء معينة من الـ State بنضافة
  SearchState copyWith({
    String? searchQuery,
    List<Contact>? allContacts,
    List<ApplicationModel>? filteredApps,
    List<Contact>? filteredContacts,
    bool? isContactsLoading,
  }) {
    return SearchState(
      searchQuery: searchQuery ?? this.searchQuery,
      allContacts: allContacts ?? this.allContacts,
      filteredApps: filteredApps ?? this.filteredApps,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      isContactsLoading: isContactsLoading ?? this.isContactsLoading,
    );
  }
}
