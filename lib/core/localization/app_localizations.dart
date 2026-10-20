import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  const AppLocalizations(this._values);

  final Map<String, dynamic> _values;

  static const fallback = AppLocalizations({
    'app': {
      'name': 'daymark.',
      'language': 'Language',
      'spanish': 'Spanish',
      'english': 'English',
    },
    'navigation': {
      'home': 'Home',
      'notes': 'Notes',
      'tasks': 'Tasks',
      'dates': 'Dates',
      'settings': 'Settings',
    },
    'home': {
      'welcome': 'A place for your little ideas.',
      'description': 'Write, draw, and keep your moments offline.',
      'stickyNotes': 'Sticky Notes',
      'stickyNotesDescription': 'Write down an idea before it gets away.',
      'growing': 'Your space is growing',
      'comingSoon': 'Tasks and important dates will live here.',
    },
    'notes': {
      'title': 'sticky notes',
      'search': 'Search notes',
      'dateFilter': 'Filter by date',
      'clearFilters': 'Clear filters',
      'empty': 'No notes yet',
      'emptyDescription': 'Write or draw your first idea.',
      'noMatches': 'No matches',
      'noMatchesDescription': 'Try different text or a different date.',
      'drawingIncluded': 'Drawing included',
      'addNote': 'Add note',
      'titleLabel': 'Title',
      'subtitleLabel': 'Subtitle',
      'noteLabel': 'Note',
      'noteHint': 'Write a note',
      'drawingOptional': 'Add a drawing (optional)',
      'size': 'Size',
      'clearDrawing': 'Clear drawing',
      'erase': 'Erase',
      'usePen': 'Use pen',
    },
    'settings': {
      'title': 'Ajustes',
      'languageDescription': 'Elige el idioma que prefieras para Daymark.',
      'styleTitle': 'Estilo visual',
      'styleDescription':
          'Suave, expresivo o limpio según el estilo seleccionado.',
      'softDescription':
          'Formas redondeadas, sombras suaves y una lectura tranquila.',
      'playfulDescription':
          'Titulares expresivos, formas creativas y un toque alegre.',
      'minimalDescription':
          'Una jerarquía limpia, formas sencillas y poca decoración.',
      'paletteTitle': 'Paleta de color',
      'reset': 'Restablecer apariencia',
      'soft': 'Suave',
      'playful': 'Juguetón',
      'minimal': 'Minimalista',
      'vanilla': 'Vainilla',
      'sage': 'Salvia',
      'rose': 'Rosa',
      'sky': 'Cielo',
      'lavender': 'Lavanda',
      'peach': 'Melocotón',
    },
    'errors': {
      'emptyNote': 'Note content cannot be empty.',
      'saveNote': 'Unable to save the note. Please try again.',
      'loadNotes': 'Unable to load notes. Please try again.',
    },
  });

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? fallback;

  String get appName => _read('app.name', 'daymark.');
  String get language => _read('app.language', 'Language');
  String get spanish => _read('app.spanish', 'Spanish');
  String get english => _read('app.english', 'English');

  String navigation(String key) => _read('navigation.$key', key);
  String home(String key) => _read('home.$key', key);
  String notes(String key) => _read('notes.$key', key);
  String settings(String key) => _read('settings.$key', key);
  String error(String key) => _read('errors.$key', key);

  String _read(String path, String fallbackValue) {
    dynamic value = _values;
    for (final segment in path.split('.')) {
      if (value is! Map || !value.containsKey(segment)) {
        return fallbackValue;
      }
      value = value[segment];
    }
    return value is String ? value : fallbackValue;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final language = locale.languageCode == 'es' ? 'es' : 'en';
    final json = await rootBundle.loadString('assets/i18n/$language.json');
    return AppLocalizations(
      Map<String, dynamic>.from(jsonDecode(json) as Map<String, dynamic>),
    );
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
