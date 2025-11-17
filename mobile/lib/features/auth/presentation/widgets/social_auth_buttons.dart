import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback? onApplePressed;

  const SocialAuthButtons({
    super.key,
    required this.onGooglePressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mostrar botón de Apple solo en iOS
    final showAppleButton = Platform.isIOS && onApplePressed != null;

    return Row(
      children: [
        // Google button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGooglePressed,
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                // Fallback si no existe la imagen
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: Text(
              showAppleButton ? 'Google' : 'Continuar con Google',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),

        // Apple button (solo iOS)
        if (showAppleButton) ...[
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onApplePressed,
              icon: const Icon(Icons.apple, size: 24),
              label: const Text(
                'Apple',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
