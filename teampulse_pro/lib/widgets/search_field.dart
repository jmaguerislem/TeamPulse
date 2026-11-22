import 'package:flutter/material.dart';

import '../core/app_tokens.dart';
import '../l10n/app_localizations.dart';

/// Barre de recherche avec bouton « effacer ».
class SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.page,
        0,
        AppSpace.page,
        AppSpace.m,
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
        },
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l.clearSearch,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onChanged('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
