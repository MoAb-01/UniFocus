import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const String _prefLanguageKey = 'unifocus_preferred_language';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
  ];

  static bool isSupported(Locale locale) {
    return ['en', 'tr', 'ar'].contains(locale.languageCode);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'UniFocus',
      'welcome': 'Welcome',
      'login': 'Log In',
      'register': 'Sign Up',
      'logout': 'Log Out',
      'email': 'Email Address',
      'password': 'Password',
      'full_name': 'Full Name',
      'university': 'University',
      'department': 'Department / Major',
      'academic_year': 'Academic Year',
      'semester': 'Semester',
      'gpa': 'GPA / GANO',
      'gpa_not_set': 'GPA NOT SET',
      'completed_akts': 'Completed AKTS / ECTS',
      'prep_year': 'Preparatory Year',
      'year_1': '1st Year',
      'year_2': '2nd Year',
      'year_3': '3rd Year',
      'year_4': '4th Year',
      'year_5': '5th Year',
      'year_6': '6th Year',
      'year_other': 'Other',
      'program_main': 'Main Program',
      'program_cap': 'ÇAP (Double Major)',
      'program_minor': 'Yandal (Minor)',
      'all_programs': 'All Programs',
      'courses': 'Courses',
      'add_course': 'Add Course',
      'edit_course': 'Edit Course',
      'delete_course': 'Delete Course',
      'tasks': 'Tasks',
      'add_task': 'Add Task',
      'no_tasks': 'No tasks scheduled. Add your first academic task!',
      'no_courses': 'No courses added yet. Start by adding a semester course.',
      'calendar': 'Calendar',
      'study_together': 'Study Together',
      'no_active_rooms': 'NO ACTIVE ROOMS',
      'no_active_rooms_desc': 'You are not currently in an arena. Host a new arena or join with an invite code.',
      'create_new_arena': 'CREATE NEW ARENA',
      'join_arena': 'JOIN ARENA',
      'enter_room_code': 'Enter Room Code',
      'host_arena': 'Host a Study Arena',
      'participants': 'Participants',
      'session_active': 'SESSION ACTIVE',
      'lobby_ready': 'LOBBY READY',
      'start_together': 'START TOGETHER',
      'break_lounge': 'Break Lounge',
      'personal_break': 'Personal Break',
      'request_group_break': 'Request Group Break',
      'group_break_requested': 'Group Break Requested',
      'mini_games': 'Mini-Games',
      'music': 'Music',
      'voice_connected': 'Voice Connected',
      'voice_muted': 'Microphone Muted',
      'speaking': 'Speaking',
      'session_summary': 'Session Summary',
      'xp_earned': 'XP Earned',
      'current_level': 'Level',
      'streak': 'Day Streak',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'turkish': 'Türkçe',
      'arabic': 'العربية',
    },
    'tr': {
      'app_name': 'UniFocus',
      'welcome': 'Hoş Geldiniz',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'logout': 'Çıkış Yap',
      'email': 'E-posta Adresi',
      'password': 'Şifre',
      'full_name': 'Ad Soyad',
      'university': 'Üniversite',
      'department': 'Bölüm / Program',
      'academic_year': 'Akademik Yıl',
      'semester': 'Dönem',
      'gpa': 'GANO / Not Ortalaması',
      'gpa_not_set': 'GANO BELİRTİLMEDİ',
      'completed_akts': 'Tamamlanan AKTS',
      'prep_year': 'Hazırlık Sınıfı',
      'year_1': '1. Sınıf',
      'year_2': '2. Sınıf',
      'year_3': '3. Sınıf',
      'year_4': '4. Sınıf',
      'year_5': '5. Sınıf',
      'year_6': '6. Sınıf',
      'year_other': 'Diğer',
      'program_main': 'Ana Program',
      'program_cap': 'ÇAP (Çift Anadal)',
      'program_minor': 'Yandal',
      'all_programs': 'Tüm Programlar',
      'courses': 'Dersler',
      'add_course': 'Ders Ekle',
      'edit_course': 'Dersi Düzenle',
      'delete_course': 'Dersi Sil',
      'tasks': 'Görevler',
      'add_task': 'Görev Ekle',
      'no_tasks': 'Planlanmış görev yok. İlk akademik görevinizi ekleyin!',
      'no_courses': 'Henüz ders eklenmedi. Dönem derslerinizi ekleyerek başlayın.',
      'calendar': 'Takvim',
      'study_together': 'Birlikte Çalış',
      'no_active_rooms': 'AKTİF ODA YOK',
      'no_active_rooms_desc': 'Şu anda bir arenada değilsiniz. Yeni bir arena oluşturun veya kod ile katılın.',
      'create_new_arena': 'YENİ ARENA OLUŞTUR',
      'join_arena': 'ARENAYA KATIL',
      'enter_room_code': 'Oda Kodunu Girin',
      'host_arena': 'Çalışma Arenası Başlat',
      'participants': 'Katılımcılar',
      'session_active': 'OTURUM AKTİF',
      'lobby_ready': 'LOBİ HAZIR',
      'start_together': 'BİRLİKTE BAŞLA',
      'break_lounge': 'Mola Salonu',
      'personal_break': 'Kişisel Mola',
      'request_group_break': 'Grup Molası İste',
      'group_break_requested': 'Grup Molası İstendi',
      'mini_games': 'Mini Oyunlar',
      'music': 'Müzik',
      'voice_connected': 'Ses Bağlandı',
      'voice_muted': 'Mikrofon Sessizde',
      'speaking': 'Konuşuyor',
      'session_summary': 'Oturum Özeti',
      'xp_earned': 'Kazanılan XP',
      'current_level': 'Seviye',
      'streak': 'Günlük Seri',
      'settings': 'Ayarlar',
      'language': 'Dil',
      'english': 'English',
      'turkish': 'Türkçe',
      'arabic': 'العربية',
    },
    'ar': {
      'app_name': 'يوني فوكس',
      'welcome': 'أهلاً بك',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'university': 'الجامعة',
      'department': 'القسم / التخصص',
      'academic_year': 'السنة الدراسية',
      'semester': 'الفصل الدراسي',
      'gpa': 'المعدل التراكمي',
      'gpa_not_set': 'المعدل غير محدد',
      'completed_akts': 'الساعات المنجزة (AKTS)',
      'prep_year': 'السنة التحضيرية',
      'year_1': 'السنة الأولى',
      'year_2': 'السنة الثانية',
      'year_3': 'السنة الثالثة',
      'year_4': 'السنة الرابعة',
      'year_5': 'السنة الخامسة',
      'year_6': 'السنة السادسة',
      'year_other': 'أخرى',
      'program_main': 'التخصص الرئيسي',
      'program_cap': 'تخصص مزدوج (ÇAP)',
      'program_minor': 'تخصص فرعي (Yandal)',
      'all_programs': 'جميع البرامج',
      'courses': 'المقررات',
      'add_course': 'إضافة مقرر',
      'edit_course': 'تعديل المقرر',
      'delete_course': 'حذف المقرر',
      'tasks': 'المهام',
      'add_task': 'إضافة مهمة',
      'no_tasks': 'لا توجد مهام حالياً. ابدأ بإضافة مهمتك الأولى!',
      'no_courses': 'لم يتم إضافة مقررات بعد. أضف مقررات الفصل الدراسي.',
      'calendar': 'التقويم',
      'study_together': 'المذاكرة الجماعية',
      'no_active_rooms': 'لا توجد غرف نشطة',
      'no_active_rooms_desc': 'أنت لست في غرفة مذاكرة حالياً. قم بإنشاء غرفة أو انضم برمز.',
      'create_new_arena': 'إنشاء غرفة جديدة',
      'join_arena': 'الانضمام للغرفة',
      'enter_room_code': 'أدخل رمز الغرفة',
      'host_arena': 'استضافة غرفة دراسة',
      'participants': 'المشاركون',
      'session_active': 'الجلسة جارية',
      'lobby_ready': 'صالة الانتظار جاهزة',
      'start_together': 'ابدأ معاً',
      'break_lounge': 'استراحة المذاكرة',
      'personal_break': 'استراحة فردية',
      'request_group_break': 'طلب استراحة جماعية',
      'group_break_requested': 'تم طلب استراحة جماعية',
      'mini_games': 'ألعاب تنشيطية',
      'music': 'الموسيقى الهادئة',
      'voice_connected': 'الصوت متصل',
      'voice_muted': 'الميكروفون مكتوم',
      'speaking': 'يتحدث الآن',
      'session_summary': 'ملخص الجلسة',
      'xp_earned': 'نقاط الخبرة المكتسبة',
      'current_level': 'المستوى',
      'streak': 'أيام الحماس المتتالية',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'english': 'English',
      'turkish': 'Türkçe',
      'arabic': 'العربية',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  bool get isRtl => locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  // Language persistence
  static Future<String> getPersistedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefLanguageKey) ?? 'en';
  }

  static Future<void> persistLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, languageCode);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
