import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_palette.dart';
import '../../../core/app_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/content_width.dart';

/// Aide : questions fréquentes dépliables + message de contact.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = context.palette;
    final faq = [
      (l.faqQ1, l.faqA1),
      (l.faqQ2, l.faqA2),
      (l.faqQ3, l.faqA3),
      (l.faqQ4, l.faqA4),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.helpTitle, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            ...faq.map((f) {
              final (q, a) = f;
              return AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                radius: 20,
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                    childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    iconColor: p.primaryInk,
                    collapsedIconColor: p.soft,
                    title: Text(q, style: AppText.title(context, size: 15)),
                    children: [Text(a, style: AppText.body(context, size: 14))],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            AppCard(
              radius: 20,
              padding: const EdgeInsets.all(18),
              color: AppColors.primary.withValues(alpha: p.isDark ? 0.18 : 0.08),
              child: Text(
                l.helpContact,
                style: AppText.title(context, size: 14, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
