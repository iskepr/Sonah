import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

export "date_time_extensions.dart";
export "string_extensions.dart";

extension StringExtension on String? {
  String get removeEl {
    if (this == null) return "";
    return this!.replaceFirst("ال", "");
  }

  // String get addEl {
  //   if (LocalData.isArabic) {
  //     return "ال$this";
  //   } else {
  //     return this;
  //   }
  // }

  String get toSearch {
    if (this == null) return "";
    return this!.toLowerCase().trim();
  }
}

extension NavigationHelpers on BuildContext {
  void close<T>([T? result]) {
    if (!mounted) return;
    // if (canPop()) {
    Navigator.of(this).pop(result);
    // } else {
    // go(kRouteHome);
    // }
  }
}

extension CubitSafeEmit<T> on Cubit<T> {
  void safeEmit(T state) {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    if (!isClosed) emit(state);
  }
}

extension FormateNames on String {
  String userName({int length = 2}) {
    final parts = split(" ");
    final finalLength = parts.length <= length ? parts.length : length;
    final List<String> names = [];
    for (var i = 0; i < finalLength; i++) {
      names.add(parts[i]);
    }
    return names.join(" ");
  }
}
