import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WebWrapper extends StatelessWidget {
  final Widget child;

  const WebWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    return Container(
      color: const Color(0xFF0A0A12),
      child: Center(
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2A2A40), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: child,
          ),
        ),
      ),
    );
  }
}
