import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../../constant.dart";
import "../../../../core/theme/colors.dart";
import "../../../../core/theme/material.dart";
import "../../data/azkar_data.dart";

class ZekrWidget extends StatelessWidget {
  const ZekrWidget({
    super.key,
    required this.onPressed,
    required this.zekr,
    required this.currentCount,
  });
  final ZekrEntity zekr;
  final int currentCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kLargePadding,
        vertical: kSmallPadding,
      ),
      child: InkWell(
        onTap: onPressed,
        onLongPress: () => Clipboard.setData(ClipboardData(text: zekr.content)),
        borderRadius: BorderRadius.circular(kSmallBorderRadius),
        child: MyMaterial(
          theme: MyMaterialTheme.glass,
          width: double.infinity,
          borderRadius: BorderRadius.circular(kSmallBorderRadius),
          padding: const EdgeInsets.all(kLargePadding),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                zekr.content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: kMediumFont + 2,
                  height: 1.5,
                ),
              ),
              RotationTransition(
                turns: AlwaysStoppedAnimation(
                  -0.1 + (Random().nextDouble() * 0.2),
                ),
                child: Text(
                  "$currentCount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: kLargeFont * 7,
                    height: 0.3,
                    color: context.colorScheme.primary.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
