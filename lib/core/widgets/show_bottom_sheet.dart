import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../constant.dart";
import "../extensions/extensions.dart";
import "../theme/colors.dart";
import "../theme/material.dart";

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({
    super.key,
    required this.child,
    this.bg = true,
    this.reverse = false,
    this.closeButton = false,
    this.actionButtons = const [],
  });

  final Widget child;
  final bool bg;
  final bool reverse;
  final bool closeButton;
  final List<Widget> actionButtons;

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => MyMaterial(
        width: double.infinity,
        theme: MyMaterialTheme.glass,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(kMediumBorderRadius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: controller,
                reverse: widget.reverse,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: kDefaultPadding,
                    right: kDefaultPadding,
                    top: widget.closeButton || widget.actionButtons.isNotEmpty
                        ? kDefaultPadding * 2
                        : kDefaultPadding,
                    bottom: kLargePadding,
                  ),
                  child: widget.child,
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.background.withOpacity(0.5),
                      context.background.withOpacity(0),
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child:
                            (widget.closeButton ||
                                widget.actionButtons.isNotEmpty)
                            ? MyMaterial(
                                margin: const EdgeInsets.all(kMediumPadding),
                                child: IconButton(
                                  icon: const Icon(LucideIcons.x),
                                  onPressed: () => context.close(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: kMediumPadding),
                      decoration: BoxDecoration(
                        color: context.secondary,
                        borderRadius: BorderRadius.circular(
                          kMediumBorderRadius,
                        ),
                      ),
                      height: 5,
                      width: 40,
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: widget.actionButtons.isNotEmpty
                            ? MyMaterial(
                                margin: const EdgeInsets.all(kMediumPadding),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    widget.actionButtons.length,
                                    (index) => widget.actionButtons[index],
                                  ),
                                ),
                              )
                            : (widget.closeButton
                                  ? const SizedBox(width: 60)
                                  : const SizedBox.shrink()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showMyBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool reverse = false,
  bool easyClose = true,
  bool? closeButton,
  List<Widget>? actionButtons,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: easyClose,
    enableDrag: easyClose,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      curve: kCurveEaseOutBack,
      reverseCurve: kCurveEaseOutBack,
      duration: kAnimationDuration,
      reverseDuration: kAnimationDuration,
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: kSmallPadding,
          right: kSmallPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MyBottomSheet(
          reverse: reverse,
          closeButton: closeButton ?? false,
          actionButtons: actionButtons ?? [],
          child: child,
        ),
      );
    },
  );
}
