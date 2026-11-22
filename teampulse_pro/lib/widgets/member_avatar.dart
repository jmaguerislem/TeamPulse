import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/models.dart';

const _avatarColors = [
  Color(0xFF5B4CFF),
  Color(0xFF0B7F65),
  Color(0xFFB45309),
  Color(0xFFE11D48),
  Color(0xFF7048E8),
];

/// Couleur stable pour un membre (même id = même couleur).
/// Teintes assez sombres pour que les initiales blanches restent lisibles.
Color avatarColor(String seed) =>
    _avatarColors[seed.hashCode.abs() % _avatarColors.length];

class MemberAvatar extends StatelessWidget {
  final Member member;
  final double size;
  const MemberAvatar({super.key, required this.member, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final base = avatarColor(member.id);
    return Semantics(
      label: member.name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              base,
              Color.lerp(base, Colors.black, 0.22)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Text(
          member.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.34,
          ),
        ),
      ),
    );
  }
}

/// Avatar de l'utilisateur connecté (dégradé de la marque).
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const UserAvatar({super.key, required this.initials, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.gradientPrimary,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
