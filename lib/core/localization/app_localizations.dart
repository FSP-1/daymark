import 'dart:convert';

import 'package:material_ui/material_ui.dart';
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
      'loading': 'Loading...',
    },
    'navigation': {
      'focus': 'Focus',
      'goals': 'Goals',
      'calendar': 'Calendar',
      'home': 'Home',
      'notes': 'Notes',
      'tasks': 'Tasks',
      'daily': 'Daily',
      'settings': 'Settings',
      'journal': 'Journal',
    },
    'help': {
      'focusHowTo': 'Focus alternates concentration sessions and breaks. Choose an activity if you want to track what you work on, then press Start. Focus prepares a short break after each session and a long break at the end of a cycle. You can pause, resume, or skip a break. Open History to see the time spent on each activity.',
      'focusActivities': 'Open Manage activities to create, edit or archive custom activities and add or remove Daily activities.',
      'focus': 'Focus opens the concentration timer.',
      'focusHistory': 'Shows recorded sessions and statistics.',
      'focusSettings': 'Changes durations, cycle and alerts.',
      'focusReset': 'Restores the duration of the current mode.',
      'focusStop': 'Stops the session and saves its recorded time.',
      'goalChecklist': 'A checklist combines steps you mark yourself and items completed through their own Daily activities.',
      'goalCounter': 'Choose how many days you want to complete one Daily activity. Each day you check it off adds one, including on nonconsecutive days.',
      'goals': 'Goals opens your personal objectives.',
      'goalAdvance': 'Increases progress for this goal.',
      'goalDecrease': 'Reduces progress for this goal.',
      'goalDate': 'Marks a goal deadline in Calendar.',
      'drawingTools': 'Drawing tools',
      'createDrawing': 'Opens the canvas to create a drawing.',
      'editDrawing': 'Opens the existing drawing for editing.',
      'eraseDrawing': 'Switches to the eraser. Drag on the canvas to erase.',
      'penDrawing': 'Switches back to the pen.',
      'undoDrawing': 'Undoes the last stroke.',
      'clearDrawing': 'Clears all strokes from the canvas. Select Save drawing to apply the change.',
      'title': 'Information',
      'navigation': 'App navigation',
      'close': 'Close',
      'home': 'Home opens the app shortcuts.',
      'notes': 'Notes opens your sticky notes.',
      'calendar': 'Calendar opens the month and year views.',
      'daily': 'Daily opens your recurring activities.',
      'journal': 'Journal opens your personal entries.',
      'settings': 'Settings opens language, style, and palette options.',
      'information': 'Information explains icons on the current screen.',
      'shortcut': 'Opens the section named on the card.',
      'addNote': 'Creates a sticky note.',
      'search': 'Searches your notes by text.',
      'filter': 'Filters notes by creation date.',
      'clearFilters': 'Clears the note search and date filters.',
      'drawing': 'Indicates that the item has a drawing.',
      'today': 'Returns to today in the month view.',
      'previous': 'Moves to the previous month or year.',
      'next': 'Moves to the next month or year.',
      'calendarDots': 'Marks days with notes or journal entries. The legend identifies each color.',
      'calendarNote': 'Creates a note for the selected day.',
      'calendarWrite': 'Opens a journal entry for the selected day if the date is today or earlier.',
      'addDaily': 'Creates a recurring activity.',
      'complete': 'Marks an activity complete or incomplete for today.',
      'editDaily': 'Edits an activity.',
      'time': 'Shows the scheduled time.',
      'reminder': 'Indicates that reminders are enabled.',
      'noReminder': 'Indicates that reminders are disabled.',
      'addEntry': 'Creates a journal entry.',
    },
    'focus': {
      'rest': 'Break',
      'howTo': 'How Focus works',
      'howToBody': 'Focus alternates concentration sessions and breaks. Choose an activity if you want to track what you work on, then press Start. Focus prepares a short break after each session and a long break at the end of a cycle. You can pause, resume, or skip a break. Open History to see the time spent on each activity.',
      'activityName': 'Activity name',
      'activityPickerHelp': 'Choose what you will do during the session. The name is saved in history. Open Manage activities to add options.',
      'activityManagerHelp': 'Activities group your concentration time. You can create your own or add activities you already have in Daily.',
      'customActivities': 'Custom activities',
      'customActivitiesHelp':
          'Tap an activity to edit it. Use the trash icon to archive it.',
      'noCustomActivities': 'You have no custom activities yet.',
      'activityActions': 'Activity options',
      'archiveActivityHelp': 'The activity will disappear from the picker. Its sessions will remain in history.',
      'dailyActivities': 'Daily activities',
      'dailyActivitiesHelp':
          'Add an existing activity to use in Focus. You can edit it in Daily.',
      'addDaily': 'Add from Daily',
      'noDailyToAdd': 'No Daily activities are available to add.',
      'unlinkDaily': 'Remove from Focus',
      'unlinkDailyHelp': 'The activity will remain available in Daily and its sessions will stay in history.',
      'subtitle': 'One thing at a time.',
      'focus': 'Concentration',
      'shortBreak': 'Short break',
      'longBreak': 'Long break',
      'ready': 'Ready',
      'running': 'In progress',
      'paused': 'Paused',
      'start': 'Start',
      'pause': 'Pause',
      'resume': 'Resume',
      'stop': 'Stop',
      'reset': 'Reset',
      'skip': 'Skip break',
      'stopConfirm': 'Stop this session and keep its recorded time?',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'today': 'Your focus today',
      'time': 'Time',
      'sessions': 'Sessions',
      'breaks': 'Breaks',
      'activity': 'Activity',
      'activities': 'Manage activities',
      'none': 'None',
      'history': 'History',
      'settings': 'Focus settings',
      'cycleLabel': 'Session {current} of {total}',
      'save': 'Save',
      'error': 'Unable to read or save Focus data. Try again.',
      'goalReference': 'Link a goal for reference. Current goals count Daily completions, so this session keeps its own time record.',
      'newActivity': 'New activity',
      'editActivity': 'Edit activity',
      'archive': 'Archive',
      'perCycle': 'Sessions before a long break',
      'autoBreak': 'Start breaks automatically',
      'autoFocus': 'Start focus sessions automatically',
      'sound': 'Sound on completion',
      'vibration': 'Vibration on completion',
      'cycleDuration': 'Total cycle time, including breaks',
      'defaults': 'Restore defaults',
      'week': 'This week',
      'month': 'This month',
      'byActivity': 'Time by activity',
      'noHistory': 'No sessions in this period.',
      'recent': 'Recorded sessions',
      'dates': 'Filter by date',
      'clearDates': 'Clear dates',
      'allActivities': 'All activities',
      'completed': 'Completed',
      'interrupted': 'Interrupted',
      'detail': 'Session details',
      'delete': 'Delete session',
      'deleteConfirm': 'Delete this session from history and Calendar?',
    },
    'goals': {
      'details': 'Dates and appearance',
      'checklistSetup':
          'Add personal steps or link existing Daily activities as steps.',
      'changeDaily': 'Change Daily activity',
      'chooseDaily': 'Choose a Daily activity',
      'noAvailableDaily': 'No activities are available to link. Create an activity in Daily first.',
      'linkedDaily': 'Linked Daily activity',
      'counterNeedsDaily':
          'Choose an existing Daily activity before saving this goal.',
      'counterFromDaily': 'Complete the linked activity in Daily to count one day toward this goal.',
      'dailyRequired': 'This activity is required by a counter goal. Change its linked activity in Goals before deleting it.',
      'dailyCredits': 'Daily contributions: {count}',
      'dailyStep': 'Completed through Daily',
      'minimumCounter': 'Enter an amount of at least {count} to keep the Daily contributions.',
      'subtitle': 'Set personal goals and track your progress.',
      'total': 'Goals',
      'all': 'All',
      'active': 'Active',
      'completed': 'Completed',
      'new': 'New goal',
      'edit': 'Edit goal',
      'delete': 'Delete goal',
      'deleteMessage': 'Delete this goal and all of its steps?',
      'title': 'Title',
      'description': 'Description',
      'icon': 'Icon',
      'color': 'Color',
      'start': 'Start date',
      'deadline': 'Deadline',
      'noDeadline': 'No deadline',
      'removeDeadline': 'Remove deadline',
      'tracking': 'Tracking method',
      'checklist': 'Checklist',
      'counter': 'Counter',
      'manual': 'Manual',
      'target': 'Days to complete',
      'unit': 'Unit',
      'required': 'Enter a title.',
      'invalidTarget': 'Enter a positive whole number.',
      'invalidDate': 'The deadline must be on or after the start date.',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'changeTracking': 'Change tracking method',
      'changeTrackingMessage':
          'Progress recorded with the previous method will be lost.',
      'saveError': 'Could not save the change. Try again.',
      'loadError': 'Could not load goals. Try again.',
      'empty': 'There are no goals in this filter.',
      'missing': 'This goal is no longer available.',
      'overdue': 'Overdue',
      'advance': 'Advance',
      'decrease': 'Reduce progress',
      'editCounter': 'Edit current amount',
      'invalidCounter': 'Enter a valid amount of zero or more.',
      'addStep': 'Add step',
      'editStep': 'Edit step',
      'deleteStep': 'Delete step',
      'up': 'Move step up',
      'down': 'Move step down',
      'stepsProgress': '{current} of {target} steps complete',
      'counterProgress': '{current} of {target}',
      'icon_target': 'Target',
      'icon_book': 'Reading',
      'icon_fitness': 'Fitness',
      'icon_project': 'Project',
      'icon_language': 'Languages',
      'color_primary': 'Primary',
      'color_secondary': 'Secondary',
      'color_tertiary': 'Tertiary',
    },
    'navSettings': {
      'title': 'Navigation',
      'description': 'Choose and reorder the shortcuts in the bottom bar.',
      'selected': 'Selected shortcuts',
      'always': 'Always visible',
      'limit': 'Remove a shortcut to add another one.',
      'error': 'Could not save navigation. Change a shortcut or restore defaults to retry.',
      'preview': 'Preview',
      'onlyHome': 'Home only. The bottom bar is hidden.',
      'restore': 'Restore defaults',
      'up': 'Move up',
      'down': 'Move down',
    },
    'home': {
      'welcome': 'Your notes, lists, and plans',
      'description': 'Write, draw, and keep your moments offline.',
      'stickyNotes': 'Notes and lists',
      'stickyNotesDescription': 'Write notes, make lists, and save drawings.',
      'dailyDescription': 'Small steps make a meaningful day.',
      'growing': 'Your space is growing',
      'comingSoon': 'Tasks and important dates will live here.',
    },
    'notes': {
      'saveChanges': 'Save changes',
      'moreItems': '+{count} more',
      'checklistProgress': '{checked} of {total} complete',
      'format_text': 'Text',
      'format_checklist': 'Checklist',
      'format_numbered': 'Numbered',
      'itemHint': 'Enter an item',
      'addItem': 'Add item',
      'removeItem': 'Remove item',
      'title': 'Notes and lists',
      'listDescription': 'Keep notes, lists, and drawings in one place.',
      'reading': 'Note',
      'editNote': 'Edit note',
      'untitled': 'Untitled note',
      'deleteNote': 'Delete note',
      'deleteConfirmation': 'Delete this note? This cannot be undone.',
      'search': 'Search notes',
      'dateFilter': 'Filter by date',
      'clearFilters': 'Clear filters',
      'empty': 'No notes yet',
      'emptyDescription': 'Create a note, a list, or a drawing.',
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
      'undoDrawing': 'Undo stroke',
      'erase': 'Erase',
      'usePen': 'Use pen',
    },
    'daily': {
      'linkedGoal': 'Linked goal',
      'noGoal': 'No linked goal',
      'goalContribution': 'Each completed day adds one unit, one percentage point, or completes the next pending step.',
      'title': 'Daily',
      'eyebrow': 'Daily',
      'description': 'Small steps make a meaningful day.',
      'activitiesHeading': 'Your activities',
      'activityCount': '{count} activities',
      'progress': 'Daily progress',
      'progressComplete': 'Everything completed. Great job!',
      'progressKeepGoing': 'Keep going, you are doing great!',
      'empty': 'No daily activities yet',
      'emptyDescription': 'Add something you want to accomplish every day.',
      'add': 'Add activity',
      'edit': 'Edit activity',
      'name': 'Activity',
      'nameHint': 'e.g. Read for 30 minutes',
      'icon': 'Activity icon',
      'iconOption': 'Select activity icon',
      'schedule': 'Schedule',
      'anytime': 'Anytime',
      'specificTime': 'Specific time',
      'notifications': 'Enable notifications',
      'notificationDescription':
          'Receive a reminder every day at the selected time.',
      'notificationEnabled': 'Reminder enabled',
      'notificationDisabled': 'No reminder',
      'completed': 'Completed',
      'incomplete': 'Incomplete',
      'delete': 'Delete activity',
      'deleteConfirmation': 'Delete this daily activity?',
      'cancel': 'Cancel',
      'save': 'Save',
      'permissionDenied':
          'Notifications are not available. You can try again in settings.',
    },
    'drawing': {
      'createDrawing': 'Create drawing',
      'editDrawing': 'Edit drawing',
      'drawingEditorTitle': 'My drawing',
      'deleteDrawing': 'Delete drawing',
      'deleteDrawingConfirmation':
          'Remove this drawing? The removal takes effect when you save.',
      'confirmDeleteDrawing': 'Delete',
      'saveDrawing': 'Save drawing',
      'cancel': 'Cancel',
    },
    'calendar': {
      'undatedNotes': 'Undated notes',
      'filter': 'Filter by type',
      'allTypes': 'All types',
      'noMatches': 'No content of this type for the selected day.',
      'completedDaily': 'Completed Daily activities',
      'dailyLoadError': 'Unable to load completed Daily activities.',
      'description': 'Your life, day by day.',
      'today': 'Today',
      'month': 'Month',
      'year': 'Year',
      'previous': 'Previous period',
      'next': 'Next period',
      'empty': 'Nothing scheduled for this day.',
      'loadError': 'Unable to load calendar content. Try again.',
      'note': 'Note',
      'journalEntry': 'Journal entry',
      'writeJournal': 'Write journal',
      'associatedDate': 'Calendar date',
      'noDate': 'No date assigned',
      'removeDate': 'Remove date',
    },
    'journal': {
      'futureDate':
          'Journal entries can only be saved for today or an earlier date.',
      'title': 'Journal',
      'subtitle': 'A quiet place for your days, in your own words.',
      'newEntry': 'New entry',
      'edit': 'Edit entry',
      'save': 'Save',
      'date': 'Date',
      'titleHint': 'Give this day a title',
      'contentHint': 'Write freely...',
      'reading': 'Entry',
      'untitled': 'Untitled day',
      'empty': 'Your journal is waiting',
      'emptyDescription':
          'Keep a thought, a memory, or a small moment from today.',
      'delete': 'Delete entry',
      'deleteConfirmation': 'Delete this journal entry? This cannot be undone.',
      'cancel': 'Cancel',
      'discard': 'Discard',
      'discardTitle': 'Discard changes?',
      'discardDescription': 'Your changes have not been saved.',
      'drawingEntry': 'Entry with drawing',
      'emptyJournal': 'Write something or add a drawing before saving.',
      'saveJournal': 'Unable to save the entry. Please try again.',
      'loadJournal': 'Unable to load the journal. Please try again.',
      'deleteJournal': 'Unable to delete the entry. Please try again.',
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
      'deleteNote': 'Unable to delete the note. Please try again.',
      'loadNotes': 'Unable to load notes. Please try again.',
      'invalidDaily': 'Enter an activity name and a valid time.',
      'loadDaily': 'Unable to load daily activities. Please try again.',
      'saveDaily': 'Unable to save the activity. Please try again.',
      'deleteDaily': 'Unable to delete the activity. Please try again.',
      'completionDaily': 'Unable to update completion. Please try again.',
      'notificationUnavailable':
          'The activity was saved, but notifications are unavailable.',
    },
  });

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? fallback;

  String get appName => _read('app.name', 'daymark.');
  String get language => _read('app.language', 'Language');
  String get spanish => _read('app.spanish', 'Spanish');
  String get english => _read('app.english', 'English');
  String get loading => _read('app.loading', 'Loading...');

  String navigation(String key) => _read('navigation.$key', key);
  String home(String key) => _read('home.$key', key);
  String goals(String key) => _read('goals.$key', key);
  String focus(String key) => _read('focus.$key', key);
  String navSettings(String key) => _read('navSettings.$key', key);
  String help(String key) => _read('help.$key', key);
  String notes(String key) => _read('notes.$key', key);
  String daily(String key) => _read('daily.$key', key);
  String journal(String key) => _read('journal.$key', key);
  String calendar(String key) => _read('calendar.$key', key);
  String drawing(String key) => _read('drawing.$key', key);
  String notification(String key) => _read('notification.$key', key);
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
