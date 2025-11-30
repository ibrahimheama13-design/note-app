import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/notes/data/repositories/firebase_notes_repository.dart';
import 'features/notes/domain/usecases/add_note.dart';
import 'features/notes/domain/usecases/delete_note.dart';
import 'features/notes/domain/usecases/get_all_notes.dart';
import 'features/notes/domain/usecases/update_note.dart';
import 'features/notes/presentation/providers/notes_provider.dart';
import 'features/notes/presentation/screens/notes_screen_clean.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handle Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform Error: $error');
      return true;
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('خطأ في تهيئة Firebase: $e');
      runApp(ErrorApp(error: e.toString()));
      return;
    }

    // Initialize repositories
    final authRepository = FirebaseAuthRepository();
    final notesRepository = FirebaseNotesRepository();

    // Initialize auth use cases
    final signInWithEmailAndPassword = SignInWithEmailAndPassword(authRepository);
    final signUpWithEmailAndPassword = SignUpWithEmailAndPassword(authRepository);
    final signOut = SignOut(authRepository);

    // Initialize notes use cases
    final getAllNotes = GetAllNotes(notesRepository);
    final addNote = AddNote(notesRepository);
    final updateNote = UpdateNote(notesRepository);
    final deleteNote = DeleteNote(notesRepository);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              signInWithEmailAndPassword: signInWithEmailAndPassword,
              signUpWithEmailAndPassword: signUpWithEmailAndPassword,
              signOut: signOut,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => NotesProvider(
              getAllNotes: getAllNotes,
              addNote: addNote,
              updateNote: updateNote,
              deleteNote: deleteNote,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught Error: $error');
    debugPrint('Stack: $stack');
  });
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'خطأ في تهيئة التطبيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF667eea),
                  brightness: Brightness.light,
                ).copyWith(
                  surface: const Color(0xFFf8f9fa),
                  primary: const Color(0xFF667eea),
                  secondary: const Color(0xFF764ba2),
                  tertiary: const Color(0xFFf093fb),
                ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFFf8f9fa),
              foregroundColor: Color(0xFF667eea),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              elevation: 8,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF667eea),
                  brightness: Brightness.dark,
                ).copyWith(
                  surface: const Color(0xFF0f0e17),
                  primary: const Color(0xFF667eea),
                  secondary: const Color(0xFF764ba2),
                  tertiary: const Color(0xFFbb86fc),
                ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFF0f0e17),
              foregroundColor: Color(0xFFbb86fc),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              elevation: 8,
            ),
          ),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          locale: localeProvider.locale,
          supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Use isInitialized and currentUser instead of StreamBuilder
              // This prevents logout issues when theme/locale changes
              if (!authProvider.isInitialized) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (authProvider.currentUser != null) {
                return const NotesScreen();
              }

              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}
