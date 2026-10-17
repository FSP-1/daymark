import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  const AppLocalizations(this._values);

  final Map<String, dynamic> _values;

  static const fallback = AppLocalizations({
    'app': {
      'name': 'daymark.',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'Inglés',
    },
    'navigation': {
      'home': 'Inicio',
      'notes': 'Notas',
      'tasks': 'Tareas',
      'dates': 'Fechas',
      'settings': 'Ajustes',
    },
    'home': {
      'welcome': 'Un lugar para tus pequeñas ideas.',
      'description': 'Escribe, dibuja y guarda tus momentos sin conexión.',
      'stickyNotes': 'Notas adhesivas',
      'stickyNotesDescription': 'Anota una idea antes de que se escape.',
      'growing': 'Tu espacio está creciendo',
      'comingSoon': 'Las tareas y fechas importantes estarán aquí.',
    },
    'notes': {
      'title': 'notas adhesivas',
      'search': 'Buscar notas',
      'dateFilter': 'Filtrar por fecha',
      'clearFilters': 'Limpiar filtros',
      'empty': 'Aún no hay notas',
      'emptyDescription': 'Escribe o dibuja tu primera idea.',
      'noMatches': 'No hay coincidencias',
      'noMatchesDescription': 'Prueba con otro texto o fecha.',
      'drawingIncluded': 'Dibujo incluido',
      'addNote': 'Añadir nota',
      'titleLabel': 'Título',
      'subtitleLabel': 'Subtítulo',
      'noteLabel': 'Nota',
      'noteHint': 'Escribe una nota',
      'drawingOptional': 'Añade un dibujo (opcional)',
      'size': 'Tamaño',
      'clearDrawing': 'Limpiar dibujo',
      'erase': 'Borrar',
      'usePen': 'Usar lápiz',
    },
    'errors': {
      'emptyNote': 'El contenido de la nota no puede estar vacío.',
      'saveNote': 'No se pudo guardar la nota. Inténtalo de nuevo.',
      'loadNotes': 'No se pudieron cargar las notas. Inténtalo de nuevo.',
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
      if (value is! Map<String, dynamic> || !value.containsKey(segment)) {
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
