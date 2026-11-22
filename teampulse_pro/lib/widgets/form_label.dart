import 'package:flutter/material.dart';

import '../core/app_text.dart';

/// Libellé visible au-dessus d'un champ (jamais seulement un placeholder).
class FormLabel extends StatelessWidget {
  final String text;
  final bool required;
  final double top;

  const FormLabel(this.text, {super.key, this.required = false, this.top = 20});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AppText.title(context, size: 14),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFE11D48)),
              ),
          ],
        ),
      ),
    );
  }
}
