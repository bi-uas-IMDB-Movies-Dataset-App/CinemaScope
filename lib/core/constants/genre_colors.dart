import 'package:flutter/material.dart';

class GenreColors {
  static List<Color> gradient(String? genre) {
    final g = (genre ?? '').toLowerCase();
    if (g.contains('action')) return [const Color(0xFF5A1F1F), const Color(0xFF1F1A2B)];
    if (g.contains('adventure')) return [const Color(0xFF1D3A4A), const Color(0xFF1B2538)];
    if (g.contains('animation')) return [const Color(0xFF3B2A5A), const Color(0xFF1F2940)];
    if (g.contains('biography')) return [const Color(0xFF4A3720), const Color(0xFF20253A)];
    if (g.contains('comedy')) return [const Color(0xFF4A3B12), const Color(0xFF2A2238)];
    if (g.contains('crime')) return [const Color(0xFF3A2332), const Color(0xFF1D2338)];
    if (g.contains('drama')) return [const Color(0xFF2B2748), const Color(0xFF1B2A3A)];
    if (g.contains('family')) return [const Color(0xFF2C3F1A), const Color(0xFF1B2C38)];
    if (g.contains('fantasy')) return [const Color(0xFF3E1F5A), const Color(0xFF1E2A3D)];
    if (g.contains('film-noir')) return [const Color(0xFF202025), const Color(0xFF121722)];
    if (g.contains('history')) return [const Color(0xFF4B2F1D), const Color(0xFF1F273A)];
    if (g.contains('horror')) return [const Color(0xFF4A1717), const Color(0xFF191625)];
    if (g.contains('music')) return [const Color(0xFF2A1F4A), const Color(0xFF1C2C45)];
    if (g.contains('musical')) return [const Color(0xFF4A2F13), const Color(0xFF2A2340)];
    if (g.contains('mystery')) return [const Color(0xFF2F2351), const Color(0xFF1A2636)];
    if (g.contains('romance')) return [const Color(0xFF5A213F), const Color(0xFF1E263A)];
    if (g.contains('sci-fi')) return [const Color(0xFF103A4C), const Color(0xFF1C2240)];
    if (g.contains('sport')) return [const Color(0xFF1F4A2A), const Color(0xFF1A2A3D)];
    if (g.contains('thriller')) return [const Color(0xFF2E203F), const Color(0xFF182234)];
    if (g.contains('war')) return [const Color(0xFF3F2F1B), const Color(0xFF1D2634)];
    if (g.contains('western')) return [const Color(0xFF4B2A1A), const Color(0xFF202A3A)];
    return [const Color(0xFF1C2235), const Color(0xFF141824)];
  }

  static Color accent(String? genre) {
    final colors = gradient(genre);
    return Color.lerp(colors.first, colors.last, 0.35) ?? colors.first;
  }
}
