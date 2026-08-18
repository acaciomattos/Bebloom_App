import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/lessons/lesson_detail_screen.dart';
import 'features/lessons/lesson_library_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/vocabulary/vocabulary_screen.dart';
import 'shared/models/course_content.dart';
import 'shared/services/app_controller.dart';

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!.notifier!;
  }
}

class EnglishTutorDemoApp extends StatelessWidget {
  const EnglishTutorDemoApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0EA5E9),
    ).copyWith(
      primary: const Color(0xFF0284C7),
      secondary: const Color(0xFF22C55E),
      surface: const Color(0xFFF8FAFC),
    );

    return AppScope(
      notifier: controller,
      child: MaterialApp(
        title: 'English Tutor Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8FAFC),
            foregroundColor: Color(0xFF0F172A),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.4),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final tabs = [
      HomeScreen(
        onOpenLibrary: () => setState(() => _selectedIndex = 1),
        onOpenProgress: () => setState(() => _selectedIndex = 3),
        onContinueStudy: () async {
          final lesson = controller.continueLesson;
          if (lesson != null) {
            await _openLesson(lesson);
          }
        },
      ),
      LessonLibraryScreen(onOpenLesson: _openLesson),
      VocabularyScreen(onOpenLesson: _openLesson),
      ProgressScreen(onOpenLibrary: () => setState(() => _selectedIndex = 1)),
    ];

    const titles = ['Inicio', 'Biblioteca', 'Vocabulario', 'Progresso'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: tabs)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Aulas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmarks_rounded),
            label: 'Vocabulario',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progresso',
          ),
        ],
      ),
    );
  }

  Future<void> _openLesson(Lesson lesson) async {
    final controller = AppScope.of(context);
    await controller.registerLessonOpened(lesson.id);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonDetailScreen(lessonId: lesson.id),
      ),
    );
  }
}
