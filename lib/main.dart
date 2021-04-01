import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:notesy_offline/models/home_model.dart';
import 'package:notesy_offline/routes.dart';
import 'package:notesy_offline/screens/notes_page.dart';
import 'package:notesy_offline/services/authentication.dart';
import 'package:notesy_offline/services/note_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/note_model.dart';
import 'screens/home_page.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(LabelAdapter());
  await Firebase.initializeApp();
  flutterLocalNotificationsPlugin1 = FlutterLocalNotificationsPlugin();
  runApp(MyApp());
}

class Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Text("Debug"),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static late final GlobalKey<NavigatorState>? navigatorKey;
  @override
  Widget build(BuildContext context) {
    navigatorKey = GlobalKey<NavigatorState>();
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null),
        ChangeNotifierProvider(create: (context) => NoteService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Notesy',
        // theme: ThemeData.dark(),
        theme: ThemeData(
          textTheme: GoogleFonts.ubuntuTextTheme(
            Theme.of(context).textTheme,
          ),
          brightness: Brightness.dark,
        ),
        initialRoute: '/',
        onGenerateRoute: GenerateRoute.generateRoute,
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => ChangeNotifierProvider(
                create: (context) => HomeModel(),
                // child: AuthenticationWrapper(),
                child: ChangeNotifierProvider(
                  create: (context) => NoteService(),
                  child: LocalNotesPage(),
                ),

                // child: FutureBuilder(
                //   future: Hive.openBox("notes"),
                //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                //     if (snapshot.connectionState == ConnectionState.done) {
                //       if (snapshot.hasError)
                //         return Text(snapshot.error.toString());
                //       else
                //         return ChangeNotifierProvider(
                //             create: (context) => NoteService(), child: LocalNotesPage());
                //     } else
                //       return Scaffold();
                //   },
                // ),
              ),
        },
        // routes: <String, WidgetBuilder>{
        //   '/': (BuildContext context) => ChangeNotifierProvider(
        //         create: (context) => HomeModel(),
        //         child: AuthenticationWrapper(),
        //       ),
        //   '/note-editor': (BuildContext context) => NoteEditor(),
        //   //'/note-viewer': (BuildContext context) => NoteViewPage(),
        // },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      try {
        return ChangeNotifierProvider(
            create: (context) => NoteService(), child: LocalNotesPage());
      } catch (e) {
        print(e);
        return Scaffold(body: SafeArea(child: Text("Hello")));
      }
    } else
      return HomePage();
  }
}
