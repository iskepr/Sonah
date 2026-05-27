import "package:android_intent_plus/android_intent.dart";

Future<void> searchInGoogleApp(String query) async {
  if (query.trim().isEmpty) return;

  final intent = AndroidIntent(
    action: "com.google.android.googlequicksearchbox.GOOGLE_SEARCH",
    arguments: {"query": query},
  );

  try {
    await intent.launch();
  } catch (e) {
    final fallbackIntent = AndroidIntent(
      action: "android.intent.action.VIEW",
      data: Uri.encodeFull("https://www.google.com/search?q=$query"),
    );
    await fallbackIntent.launch();
  }
}
