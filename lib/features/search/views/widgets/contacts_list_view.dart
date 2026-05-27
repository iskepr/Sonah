import "package:flutter/material.dart";
import "package:flutter_contacts/models/contact/contact.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../constant.dart";
import "../../../../core/theme/colors.dart";
import "../../service/start_call_service.dart";

class ContactsListView extends StatelessWidget {
  const ContactsListView({super.key, required this.filteredContacts});

  final List<Contact> filteredContacts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredContacts.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: contact.photo != null && contact.photo!.thumbnail != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(kCircleBorderRadius),
                  child: Image.memory(
                    contact.photo!.thumbnail!,
                    width: kLargeFont * 2,
                  ),
                )
              : Icon(
                  LucideIcons.circleUserRound300,
                  size: kLargeFont * 2,
                  color: context.primary,
                ),
          title: Text(contact.displayName ?? ""),
          subtitle: Text(
            contact.phones
                .map((phone) => phone.number.replaceAll(" ", ""))
                .join(" ,"),
          ),
          onTap: () async => await startCall(contact, context: context),
        );
      },
    );
  }
}
