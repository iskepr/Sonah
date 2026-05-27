import "package:android_intent_plus/android_intent.dart";
import "package:flutter/material.dart";
import "package:flutter_contacts/models/contact/contact.dart";
import "package:permission_handler/permission_handler.dart";

import "../../../core/extensions/extensions.dart";
import "../../../core/utils/show_message.dart";
import "../../../core/widgets/show_dialog.dart";

Future<void> startCall(Contact contact, {required BuildContext context}) async {
  if (contact.phones.isEmpty) {
    showMessage("لا يوجد أرقام مسجلة لجهة الاتصال هذه", isError: true);
    return;
  }

  String selectedNumber = contact.phones.first.number;

  if (contact.phones.length > 1) {
    final String? chosenNumber = await showCustomDialog<String>(
      title: "اختر الرقم لـ ${contact.displayName}",
      child: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: contact.phones.length,
          itemBuilder: (context, index) {
            final phone = contact.phones[index];
            return ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone.number),
              subtitle: Text(phone.label.label.name),
              onTap: () => context.close(phone.number),
            );
          },
        ),
      ),
    );

    if (chosenNumber == null) return;
    selectedNumber = chosenNumber;
  }

  var status = await Permission.phone.status;
  if (!status.isGranted) status = await Permission.phone.request();

  if (status.isGranted) {
    final int? selectedSimSlot = await showCustomDialog<int>(
      title: "اختر خط الاتصال",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sim_card),
            title: const Text("الخط الأول"),
            onTap: () => context.close(0),
          ),
          ListTile(
            leading: const Icon(Icons.sim_card),
            title: const Text("الخط الثاني"),
            onTap: () => context.close(1),
          ),
        ],
      ),
    );

    final cleanNumber = selectedNumber.replaceAll(" ", "");

    final intent = AndroidIntent(
      action: "android.intent.action.CALL",
      data: "tel:$cleanNumber",
      arguments: {
        "com.android.phone.extra.slot": selectedSimSlot,
        "phone": selectedSimSlot,
        "simSlot": selectedSimSlot,
      },
    );

    try {
      await intent.launch();
    } catch (e) {
      debugPrint("فشل الاتصال المباشر، جاري فتح لوحة الاتصال كبديل: $e");
    }
  } else {
    final fallbackIntent = AndroidIntent(
      action: "android.intent.action.DIAL",
      data: "tel:$selectedNumber",
    );
    await fallbackIntent.launch();
  }
}
