import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:notesy_offline/widgets/local_notes_grid.dart';
import 'package:notesy_offline/widgets/note_card.dart' show HexColor;
import 'package:notesy_offline/models/note_model.dart';
import 'package:notesy_offline/services/note_service.dart';
import 'package:notesy_offline/widgets/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:notesy_offline/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_ex');

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class LocalNotesPage extends StatefulWidget {
  @override
  _LocalNotesPageState createState() => _LocalNotesPageState();
}

class _LocalNotesPageState extends State<LocalNotesPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _listView = false;
  @override
  void initState() {
    super.initState();
    //tz.initializeTimeZones();
    flutterLocalNotificationsPlugin1 = FlutterLocalNotificationsPlugin();
    _configureLocalTimeZone();
    var androidInit = AndroidInitializationSettings('ic_launcher');
    var initSetting = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: NotificationHelper.notificationSelected);
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  Future<dynamic>? _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "Note Reminder", "channelDescription",
        importance: Importance.high);
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0, "title", "body", generalNotificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    try {
      return FutureBuilder(
          future: Hive.openBox<Note>(
              Provider.of<NoteService>(context).strCurrentBox),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Hive.openBox<Label>("labels")
                  .then((value) => print("Labels box opened"))
                  .catchError((e) => null);
              if (snapshot.hasError)
                return Text(snapshot.error.toString());
              else
                return ValueListenableBuilder<Box<Note>>(
                  valueListenable: Provider.of<NoteService>(context)
                      .createBoxListenable(context),
                  builder: (context, boxContents, _) {
                    return Consumer<NoteService>(
                      builder: (_, noteService, __) => DefaultTextStyle(
                        style: const TextStyle(color: const Color(0xFFFEFEFE)),
                        child: Scaffold(
                          backgroundColor: Color(0xFF1f1d2b),
                          key: _scaffoldKey,
                          drawer: LocalSideBarDrawer(),
                          // appBar: _customAppBar(noteService),
                          floatingActionButton: FloatingActionButton(
                            backgroundColor: (noteService.labelColor == null)
                                ? const Color(0xFF6f6fc8)
                                : HexColor(hexColor: noteService.labelColor!),
                            child: const Icon(
                              Icons.add,
                              size: 30,
                              color: kBorderColorLight,
                            ),
                            onPressed: () {
                              //NotificationHelper.showNotification(flutterLocalNotificationsPlugin);
                              // _showNotification();
                              print(
                                  "On pressed fab : ${noteService.labelInUse}");
                              if (noteService.labelInUse == null)
                                Navigator.pushNamed(context, '/note');
                              else
                                Navigator.pushNamed(context, '/note',
                                    arguments: {
                                      'note': Note(
                                          labels: [noteService.labelInUse],
                                          color: noteService.labelColor,
                                          fromDefaultLabel: true)
                                    });
                            },
                          ),
                          //body: _buildNotesView(context),
                          body: CustomScrollView(
                            physics: BouncingScrollPhysics(),
                            slivers: <Widget>[
                              // a floating appbar
                              SliverAppBar(
                                floating: true,
                                snap: true,
                                backgroundColor:
                                    (noteService.labelColor == null)
                                        ? null
                                        : HexColor(
                                            hexColor: noteService.labelColor!),
                                // title: _topActions(context),
                                title: _topAppBar(context, noteService),
                                automaticallyImplyLeading: false,
                                centerTitle: true,
                                titleSpacing: 0,
                                // backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24), // top spacing
                              ),

                              _buildLocalNotesView(context, boxContents),

                              const SliverToBoxAdapter(
                                child: SizedBox(
                                    height:
                                        80.0), // bottom spacing make sure the content can scroll above the bottom bar
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
            } else
              return Scaffold();
          });
    } catch (e) {
      print(e);
      return Scaffold();
    }
  }

  Widget _topAppBar(BuildContext context, NoteService noteService) => Row(
        children: [
          SizedBox(width: 20.0),
          InkWell(
            child: const Icon(
              Icons.menu,
              size: 30.0,
            ),
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              noteService.labelInUse ?? 'Notesy',
              softWrap: false,
              style: GoogleFonts.ubuntu(
                color: noteService.labelInUse == null
                    ? Color(0xFFb0b0B0)
                    : Color(0xFFFEFEFE),
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            child: Icon(Icons.search),
          ),
          const SizedBox(width: 16),
          InkWell(
            child: Icon(_listView ? Icons.view_agenda : Icons.grid_view),
            onTap: () => setState(() {
              _listView = !_listView;
            }),
          ),
          const SizedBox(width: 16),
        ],
      );

  Widget _buildLocalNotesView(BuildContext context, Box<Note> boxContents) {
    if (!_listView)
      return LocalNotesStagGrid(
        boxContents: boxContents,
        onTap: _onNoteTap,
        length: boxContents.length,
      );
    else
      return LocalNotesStagGrid(
        boxContents: boxContents,
        onTap: _onNoteTap,
        length: boxContents.length,
        fit: 2,
        padding: 18.0,
      );
  }

  void _onNoteTap(Note? note) async {
    Navigator.pushNamed(context, '/note', arguments: {'note': note});
  }
}

// class NotesPage extends StatefulWidget {
//   @override
//   _NotesPageState createState() => _NotesPageState();
// }

// class _NotesPageState extends State<NotesPage> {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // final _scaffoldKey = GlobalKey<ScaffoldState>();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   bool _listView = false;
//   @override
//   void initState() {
//     super.initState();
//     //tz.initializeTimeZones();
//     flutterLocalNotificationsPlugin1 = FlutterLocalNotificationsPlugin();
//     _configureLocalTimeZone();
//     var androidInit = AndroidInitializationSettings('ic_launcher');
//     var initSetting = InitializationSettings(android: androidInit);
//     flutterLocalNotificationsPlugin.initialize(initSetting,
//         onSelectNotification: NotificationHelper.notificationSelected);
//   }

//   @override
//   void dispose() {
//     Hive.close();
//     super.dispose();
//   }

//   Future<dynamic>? _showNotification() async {
//     var androidDetails = AndroidNotificationDetails(
//         "channelId", "Note Reminder", "channelDescription",
//         importance: Importance.high);
//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails);
//     await flutterLocalNotificationsPlugin.show(
//         0, "title", "body", generalNotificationDetails);
//   }

//   @override
//   Widget build(BuildContext context) {
//     try {
//       //return StreamProvider<List<Note?>?>.value(
//       return Consumer<NoteService>(
//         builder: (_, noteService, __) {
//           return DefaultTextStyle(
//             style: const TextStyle(color: const Color(0xFFFEFEFE)),
//             child: Scaffold(
//               backgroundColor: Color(0xFF1f1d2b),
//               key: _scaffoldKey,
//               drawer: LocalSideBarDrawer(),
//               // appBar: _customAppBar(noteService),
//               floatingActionButton: FloatingActionButton(
//                 backgroundColor: (noteService.labelColor == null)
//                     ? const Color(0xFF6f6fc8)
//                     : HexColor(hexColor: noteService.labelColor!),
//                 child: const Icon(
//                   // Icons.add,
//                   Icons.add_circle_sharp,
//                   size: 30,
//                   color: kBorderColorLight,
//                 ),
//                 onPressed: () {
//                   // NotificationHelper.showNotification(
//                   //     flutterLocalNotificationsPlugin);
//                   // _showNotification();
//                   print("On pressed fab : ${noteService.labelInUse}");
//                   if (noteService.labelInUse == null)
//                     Navigator.pushNamed(context, '/note');
//                   else
//                     Navigator.pushNamed(context, '/note', arguments: {
//                       'note': Note(labels: [noteService.labelInUse])
//                     });
//                 },
//               ),
//               //body: _buildNotesView(context),
//               body: CustomScrollView(
//                 physics: BouncingScrollPhysics(),
//                 slivers: <Widget>[
//                   // a floating appbar
//                   SliverAppBar(
//                     floating: true,
//                     snap: true,
//                     backgroundColor: (noteService.labelColor == null)
//                         ? null
//                         : HexColor(hexColor: noteService.labelColor!),
//                     // title: _topActions(context),
//                     title: _topAppBar(context, noteService),
//                     automaticallyImplyLeading: false,
//                     centerTitle: true,
//                     titleSpacing: 0,
//                     // backgroundColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                   const SliverToBoxAdapter(
//                     child: SizedBox(height: 24), // top spacing
//                   ),

//                   //_buildNotesView(context),

//                   const SliverToBoxAdapter(
//                     child: SizedBox(
//                         height:
//                             80.0), // bottom spacing make sure the content can scroll above the bottom bar
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       print(e);
//       return Scaffold();
//     }
//   }

//   Widget _topAppBar(BuildContext context, NoteService noteService) => Row(
//         children: [
//           SizedBox(width: 20.0),
//           InkWell(
//             child: const Icon(
//               Icons.menu,
//               size: 30.0,
//             ),
//             onTap: () => _scaffoldKey.currentState?.openDrawer(),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               noteService.labelInUse ?? 'Notesy',
//               softWrap: false,
//               style: GoogleFonts.ubuntu(
//                 color: noteService.labelInUse == null
//                     ? Color(0xFFb0b0B0)
//                     : Color(0xFFFEFEFE),
//                 fontSize: 22,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           InkWell(
//             child: Icon(Icons.search),
//           ),
//           const SizedBox(width: 16),
//           InkWell(
//             child: Icon(_listView ? Icons.view_agenda : Icons.grid_view),
//             onTap: () => setState(() {
//               _listView = !_listView;
//             }),
//           ),
//           const SizedBox(width: 16),
//         ],
//       );

//   Consumer<List<Note?>?> _buildNotesView(BuildContext context) =>
//       Consumer<List<Note?>?>(
//         builder: (context, notes, _) {
//           print("building notes view");

//           if (notes!.isNotEmpty != true) {
//             //return DebugGrid(notes?.length, notes);
//             return NotesStagGrid(notes: notes, onTap: (note) {}, length: 0);
//           }
//           if (!_listView) {
//             return NotesStagGrid(
//               notes: notes,
//               onTap: _onNoteTap,
//               length: notes.length,
//               // onTap: (note) async {
//               //   Navigator.of(context).push(
//               //     MaterialPageRoute(
//               //       builder: (context) => NoteViewPage(note: note),
//               //     ),
//               //   );
//               // },
//             );
//           } else
//             return NotesStagGrid(
//               notes: notes,
//               onTap: _onNoteTap,
//               length: notes.length,
//               fit: 2,
//               padding: 18,
//               // onTap: (note) async {
//               //   Navigator.of(context).push(
//               //     MaterialPageRoute(
//               //       builder: (context) => NoteViewPage(note: note),
//               //     ),
//               //   );
//               // },
//             );
//           //final widget = !_listView ? NotesGrid() : NotesViewList();
//           //return widget(notes: notes, onTap: (_) {});
//         },
//       );

//   void _onNoteTap(Note? note) async {
//     Navigator.pushNamed(context, '/note', arguments: {'note': note});
//   }
// }

// //.collection("notes-2U9ZKxo3VAbtqVVCVTtT4nmPWfa2")
// // .orderBy("modifiedAt", "asc")
// /// Creates the notes query
// Stream<List<Note?>?> _createNoteStream(BuildContext context) {
//   final uid =
//       context.watch<User?>()?.uid; //Provider.of<User?>(context)?.data?.uid;
//   //sample hello2@gmail.com is "2U9ZKxo3VAbtqVVCVTtT4nmPWfa2";

//   return FirebaseFirestore.instance
//       .collection('notes-$uid')
//       .orderBy("createdAt", descending: true)
//       // .where('state', isEqualTo: 0)
//       .snapshots()
//       .handleError((e) => debugPrint('query notes failed: $e'))
//       .map((snapshot) => Note.fromQuery(snapshot));
// }

// class NotesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: SafeArea(
//           child: ListView(
//             // Important: Remove any padding from the ListView.
//             padding: EdgeInsets.zero,
//             children: [
//               ListTile(
//                 title: Text(
//                   context.read<AuthenticationService>().currentUser.email!,
//                   style: TextStyle(
//                     fontSize: 18.0,
//                   ),
//                 ),
//               ),
//               ListTile(
//                 title: Text(
//                   'Sign Out',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//                 onTap: () {
//                   context.read<AuthenticationService>().signOut();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.teal.shade600,
//         onPressed: () {
//           Navigator.of(context).pushNamed('/notes_add');
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       appBar: AppBar(
//         title: Text("Notesy"),
//       ),
//       body: SafeArea(
//         child: NotesList(),
//       ),
//     );
//   }
// }
