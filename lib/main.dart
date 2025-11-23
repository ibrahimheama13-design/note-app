import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('خطأ في تهيئة Firebase: $e');
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
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
                Text('$e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ).copyWith(surface: Colors.white),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ).copyWith(surface: Colors.grey[900]),
            useMaterial3: true,
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
              return StreamBuilder(
                stream: authProvider.authStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text(
                              'خطأ في الاتصال',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('${snapshot.error}', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasData) {
                    return const NotesScreen();
                  }

                  return const AuthScreen();
                },
              );
            },
          ),
        );
      },
    );
  }
}
