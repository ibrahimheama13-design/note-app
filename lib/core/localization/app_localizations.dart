import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';

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
      'search_by_title': 'ابحث بعنوان الملاحظة...',
      'no_search_results': 'لا توجد نتائج',
      'note_deleted': 'تم حذف الملاحظة',
      'delete_error': 'خطأ في حذف الملاحظة',
      'title_copied': 'تم نسخ العنوان',
      'content_copied': 'تم نسخ المحتوى',
      'copy_title': 'نسخ العنوان',
      'copy_content': 'نسخ المحتوى',
      'delete_note': 'حذف الملاحظة',
      'confirm_delete': 'تأكيد الحذف',
      'delete_confirm_message': 'هل أنت متأكد من حذف هذه الملاحظة؟',
      'create_note_type': 'اختر نوع الملاحظة',
      'standard_note': 'ملاحظة عادية',
      'standard_note_desc': 'ملاحظة بعنوان ومحتوى',
      'word_note': 'ملاحظة Word',
      'word_note_desc': 'صفحة بيضاء للكتابة الحرة',
      'start_writing': 'ابدأ الكتابة هنا...',
      'pages': 'صفحات',
      'page': 'صفحة',
      'add_page': 'إضافة صفحة',
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
      'search_by_title': 'Search by note title...',
      'no_search_results': 'No results found',
      'note_deleted': 'Note deleted',
      'delete_error': 'Error deleting note',
      'title_copied': 'Title copied',
      'content_copied': 'Content copied',
      'copy_title': 'Copy title',
      'copy_content': 'Copy content',
      'delete_note': 'Delete note',
      'confirm_delete': 'Confirm deletion',
      'delete_confirm_message': 'Are you sure you want to delete this note?',
      'create_note_type': 'Choose note type',
      'standard_note': 'Standard Note',
      'standard_note_desc': 'Note with title and content',
      'word_note': 'Word Note',
      'word_note_desc': 'Blank page for free writing',
      'start_writing': 'Start writing here...',
      'pages': 'pages',
      'page': 'Page',
      'add_page': 'Add Page',
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
      'search_by_title': 'Rechercher par titre...',
      'no_search_results': 'Aucun résultat trouvé',
      'note_deleted': 'Note supprimée',
      'delete_error': 'Erreur lors de la suppression',
      'title_copied': 'Titre copié',
      'content_copied': 'Contenu copié',
      'copy_title': 'Copier le titre',
      'copy_content': 'Copier le contenu',
      'delete_note': 'Supprimer la note',
      'confirm_delete': 'Confirmer la suppression',
      'delete_confirm_message': 'Êtes-vous sûr de vouloir supprimer cette note?',
      'create_note_type': 'Choisir le type de note',
      'standard_note': 'Note standard',
      'standard_note_desc': 'Note avec titre et contenu',
      'word_note': 'Note Word',
      'word_note_desc': 'Page blanche pour écriture libre',
      'start_writing': 'Commencez à écrire ici...',
      'pages': 'pages',
      'page': 'Page',
      'add_page': 'Ajouter une page',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']![key] ??
        key;
  }

  /// Safe method to get AppLocalizations - uses Provider instead of Localizations
  static AppLocalizations of(BuildContext context) {
    try {
      // Try to get locale from Provider first (safer)
      final localeProvider = context.read<LocaleProvider>();
      return AppLocalizations(localeProvider.locale);
    } catch (_) {
      // Fallback to default Arabic locale
      return AppLocalizations(const Locale('ar'));
    }
  }

  /// Create from a specific locale (for use in dialogs/sheets)
  static AppLocalizations fromLocale(Locale locale) {
    return AppLocalizations(locale);
  }
}
