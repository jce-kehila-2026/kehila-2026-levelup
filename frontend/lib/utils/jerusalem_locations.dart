/// Utility — Localized Jerusalem Locations
/// Path: lib/utils/jerusalem_locations.dart
library;

/// A single location entry with English and Arabic names.
class JerusalemLocation {
  final String en;
  final String ar;
  const JerusalemLocation({required this.en, required this.ar});

  /// Returns the localized name based on the language code.
  String name(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// Jerusalem neighborhoods and surrounding areas.
/// Sorted alphabetically by English name.
const List<JerusalemLocation> kJerusalemLocations = [
  JerusalemLocation(en: 'Abu Ghosh',                 ar: 'أبوغوش وما حولها'),
  JerusalemLocation(en: 'Abu Tor - Al-Thawri',       ar: 'أبوطور - الثوري'),
  JerusalemLocation(en: 'Al-Eizariya and Abu Dis',   ar: 'العيزرية وأبوديس'),
  JerusalemLocation(en: 'Al-Issawiya',               ar: 'العيساوية'),
  JerusalemLocation(en: 'Al-Walaja and Beit Sahour', ar: 'الولجة وبيت ساحور'),
  JerusalemLocation(en: 'Anata - Shufat Camp',       ar: 'عناتا - مخيم شعفاط'),
  JerusalemLocation(en: 'Atarot',                    ar: 'عطروت'),
  JerusalemLocation(en: 'At-Tur - Mount of Olives',  ar: 'الطور - جبل الزيتون'),
  JerusalemLocation(en: 'Beit Hanina',               ar: 'بيت حنينا'),
  JerusalemLocation(en: 'Beit Safafa',               ar: 'بيت صفافا'),
  JerusalemLocation(en: 'Jabal Al-Mukaber',          ar: 'جبل المكبر'),
  JerusalemLocation(en: 'Kafr Aqab',                 ar: 'كفر عقب'),
  JerusalemLocation(en: 'Old City',                  ar: 'البلدة القديمة ومحيطها'),
  JerusalemLocation(en: 'Other',                     ar: 'غير ذلك'),
  JerusalemLocation(en: 'Out of Jerusalem',          ar: 'خارج حدود القدس'),
  JerusalemLocation(en: 'Ras al-Amud',               ar: 'رأس العامود'),
  JerusalemLocation(en: 'Sheikh Jarrah',             ar: 'الشيخ جراح'),
  JerusalemLocation(en: "Shu'fat",                   ar: 'شعفاط'),
  JerusalemLocation(en: 'Silwan',                    ar: 'سلوان'),
  JerusalemLocation(en: 'Sur Baher',                 ar: 'صورباهر'),
  JerusalemLocation(en: 'Umm Laysun',                ar: 'أم ليسون'),
  JerusalemLocation(en: 'Umm Tuba',                  ar: 'أم طوبا'),
  JerusalemLocation(en: 'Wadi al-Joz',               ar: 'وادي الجوز'),
];
