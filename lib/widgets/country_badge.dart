import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const Map<String, _FlagMeta> _flagMap = {
  'CN': _FlagMeta('CN', Color(0xFFDE2910), Color(0xFFFFDE00)),
  'EG': _FlagMeta('EG', Color(0xFFCE1126), Colors.white),
  'GR': _FlagMeta('GR', Color(0xFF0D5EAF), Colors.white),
  'IT': _FlagMeta('IT', Color(0xFF009246), Colors.white),
  'FR': _FlagMeta('FR', Color(0xFF002395), Colors.white),
  'GB': _FlagMeta('GB', Color(0xFF012169), Colors.white),
  'DE': _FlagMeta('DE', Color(0xFF000000), Color(0xFFFFCC00)),
  'US': _FlagMeta('US', Color(0xFF3C3B6E), Colors.white),
  'JP': _FlagMeta('JP', Color(0xFFBC002D), Colors.white),
  'IN': _FlagMeta('IN', Color(0xFFFF9933), Colors.white),
  'RU': _FlagMeta('RU', Color(0xFF0039A6), Colors.white),
  'TR': _FlagMeta('TR', Color(0xFFE30A17), Colors.white),
  'IR': _FlagMeta('IR', Color(0xFF239F40), Colors.white),
  'MX': _FlagMeta('MX', Color(0xFF006847), Colors.white),
  'BR': _FlagMeta('BR', Color(0xFF009C3B), Color(0xFFFFDF00)),
  'KR': _FlagMeta('KR', Color(0xFF003478), Colors.white),
  'ES': _FlagMeta('ES', Color(0xFFC60B1E), Color(0xFFFFC400)),
  'AU': _FlagMeta('AU', Color(0xFF00008B), Colors.white),
};

class _FlagMeta {
  final String code;
  final Color bg;
  final Color fg;
  const _FlagMeta(this.code, this.bg, this.fg);
}

_FlagMeta _resolve(String code) =>
    _flagMap[code] ?? _FlagMeta(code, AppTheme.textSecondary, Colors.white);

class CountryBadge extends StatelessWidget {
  final String flagCode;
  final double fontSize;

  const CountryBadge({super.key, required this.flagCode, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final meta = _resolve(flagCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: meta.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        meta.code,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: meta.fg,
        ),
      ),
    );
  }
}

class CountryCircle extends StatelessWidget {
  final String flagCode;
  final double size;

  const CountryCircle({super.key, required this.flagCode, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final meta = _resolve(flagCode);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: meta.bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        meta.code.length > 2 ? meta.code.substring(0, 2) : meta.code,
        style: TextStyle(
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
          color: meta.fg,
        ),
      ),
    );
  }
}
