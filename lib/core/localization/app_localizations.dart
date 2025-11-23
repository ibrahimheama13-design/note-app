import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'my_notes': 'ملاحظاتي',
      'logout': 'تسجيل الخروج',
      'no_notes': 'لا توجد ملاحظات حالياً\nاضغط + لإضافة ملاحظة جديدة',
      'add': 'إضافة',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'title': 'العنوان',
      'content': 'المحتوى',
      'edit_note': 'تعديل الملاحظة',
      'add_note': 'إضافة ملاحظة',
      'error_loading': 'حدث خطأ في تحميل الملاحظات\nالرجاء المحاولة مرة أخرى',
      'delete': 'حذف',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'select_language': 'اختر اللغة',
      'profile_image': 'صورة الملف الشخصي',
      'choose_from_gallery': 'اختر من المعرض',
      'select_profile_image': 'اختر صورة الملف الشخصي',
    },
    'en': {
      'my_notes': 'My Notes',
      'logout': 'Sign Out',
      'no_notes': 'No notes yet\nTap + to add a new note',
      'add': 'Add',
      'save': 'Save',
      'cancel': 'Cancel',
      'title': 'Title',
      'content': 'Content',
      'edit_note': 'Edit Note',
      'add_note': 'Add Note',
      'error_loading': 'Error loading notes\nPlease try again',
      'delete': 'Delete',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'select_language': 'Select Language',
      'profile_image': 'Profile Image',
      'choose_from_gallery': 'Choose from Gallery',
      'select_profile_image': 'Select Profile Image',
    },
    'fr': {
      'my_notes': 'Mes notes',
      'logout': 'Se déconnecter',
      'no_notes':
          "Aucune note pour l'instant\nAppuyez sur + pour ajouter une nouvelle note",
      'add': 'Ajouter',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'title': 'Titre',
      'content': 'Contenu',
      'edit_note': 'Modifier la note',
      'add_note': 'Ajouter une note',
      'error_loading':
          'Erreur lors du chargement des notes\nVeuillez réessayer',
      'delete': 'Supprimer',
      'settings': 'Paramètres',
      'theme': 'Thème',
      'language': 'Langue',
      'light': 'Clair',
      'dark': 'Sombre',
      'select_language': 'Choisir la langue',
      'profile_image': 'Image de profil',
      'choose_from_gallery': 'Choisir dans la galerie',
      'select_profile_image': 'Sélectionner l\'image de profil',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']![key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppLocalizations(locale);
  }
}
