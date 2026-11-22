import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/content_width.dart';
import '../login/login_screen.dart';
import '../signup/signup_screen.dart';
import 'pulse_logo.dart';

/// Écran d'accueil : choix entre connexion et création de compte.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D3A8C), Color(0xFF1A1A4B), Color(0xFF12122E)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            // Halo décoratif en haut à droite.
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
            ),
            SafeArea(
              child: ContentWidth(
                maxWidth: 480,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      const ExcludeSemantics(child: PulseLogo(width: 128)),
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        child: Text(
                          'TeamPulse Pro',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.welcomeTagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD9D8F2),
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                      const Spacer(flex: 4),
                      FilledButton(
                        onPressed: () => _go(context, const LoginScreen()),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.navy,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(l.signIn),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () => _go(context, const SignupScreen()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(l.createAccount),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
