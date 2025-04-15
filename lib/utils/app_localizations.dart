import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'يلا مزرعة',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'phone_number': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'continue_with_google': 'المتابعة مع جوجل',
      'no_account': 'ليس لديك حساب؟',
      'register': 'تسجيل',
      'villas_and_resorts': 'المزارع والاستراحات',
      'explore': 'استكشاف',
      'profile': 'الملف الشخصي',
      'search': 'ابحث عن مزرعة أو استراحة...',
      'all': 'الكل',
      'top_rated': 'الأعلى تقييماً',
      'most_popular': 'الأكثر طلباً',
      'nearby': 'قريب منك',
      'filter_by': 'الفلترة حسب',
      'reset': 'إعادة ضبط',
      'pool': 'مسبح',
      'wifi': 'واي فاي',
      'barbecue': 'شواء',
      'view_all': 'عرض الكل',
      'features': 'المميزات',
      'description': 'الوصف',
      'owner': 'المالك',
      'book': 'حجز',
      'night': 'الليلة',
      'bedrooms': 'غرف نوم',
      'bathrooms': 'حمامات',
      'guests': 'أشخاص',
      'favorites': 'المفضلة',
      'bookings': 'الحجوزات',
      'ratings': 'التقييمات',
      'edit_profile': 'تعديل الملف الشخصي',
      'favorite_villas': 'المزارع المفضلة',
      'booking_history': 'سجل الحجوزات',
      'payment_methods': 'طرق الدفع',
      'settings': 'الإعدادات',
      'help_support': 'المساعدة والدعم',
      'about_app': 'عن التطبيق',
      'version': 'الإصدار',
      'cancel': 'إلغاء',
      'close': 'إغلاق',
      'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
      'no_results': 'لا توجد مزارع تطابق البحث',
      'feature_under_development': 'هذه الميزة قيد التطوير',
      'no_notifications': 'لا توجد إشعارات جديدة',
      'about_description': 'تطبيق يلا مزرعة هو منصة لاستئجار المزارع والاستراحات في المملكة العربية السعودية.',
      'all_rights_reserved': 'جميع الحقوق محفوظة',
    },
  };
  
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
