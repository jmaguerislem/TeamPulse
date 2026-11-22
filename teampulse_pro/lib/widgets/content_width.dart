import 'package:flutter/material.dart';

/// Limite la largeur du contenu sur grands écrans (tablette, bureau, web)
/// pour garder des lignes de texte lisibles. Sans effet sur un téléphone.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWidth({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
