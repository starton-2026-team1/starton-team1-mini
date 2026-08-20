import 'package:flutter/material.dart';

enum AuctionDraftChoice { primary, secondary }

Future<AuctionDraftChoice?> showAuctionDraftDialog({
  required BuildContext context,
  String? title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
}) {
  return showDialog<AuctionDraftChoice>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF212124),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF212124),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, AuctionDraftChoice.primary),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF292D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pop(context, AuctionDraftChoice.secondary),
                  child: Text(
                    secondaryLabel,
                    style: const TextStyle(
                      color: Color(0xFF212124),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
