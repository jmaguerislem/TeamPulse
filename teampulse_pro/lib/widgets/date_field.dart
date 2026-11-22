import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/project_ui.dart';
import 'form_label.dart';

/// Champ « date » : libellé visible + sélecteur de date au toucher.
class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label, required: true),
        Semantics(
          button: true,
          label: '$label, ${fmtDate(value)}',
          onTap: () => _pick(context),
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _pick(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(
                fmtDate(value),
                style: AppText.title(context, size: 15, weight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
