import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/firebase_options.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/pages/auth_page.dart';
import 'package:meet_christ/pages/home.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/repositories/events_repository.dart';
import 'package:meet_christ/repositories/file_repository.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/event_service.dart' hide CommunityGroupService;
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/auth_view_model.dart';
import 'package:meet_christ/view_models/community_view_model.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/view_models/new_community_group_view_model.dart';
import 'package:meet_christ/view_models/new_community_view_model.dart';
import 'package:meet_christ/view_models/new_event_view_model.dart';
import 'package:meet_christ/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

User? user;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  var factory = BackendAuthFactory(type: BackendType.firestore);
  GetIt.I.registerSingleton<IAuthRepository>(factory.getRepository());
  GetIt.I.registerSingleton<FileRepository>(FileRepository());
  GetIt.I.registerSingleton<DatabaseService2<String, EventDto>>(
    EventDataSource(),
  );

  GetIt.I.registerSingleton<EventService>(
    EventService(
      adapter: GetIt.I.get<DatabaseService2<String, EventDto>>(),
      fileRepository: GetIt.I.get<FileRepository>(),
    ),
  );
  GetIt.I.registerSingleton<CommunityDataSource>(CommunityDataSource());
  GetIt.I.registerSingleton<DatabaseService2<String, User>>(
    FirestoreUserRepository(),
  );

  GetIt.I.registerSingleton<DatabaseService2<String, CommunityDto>>(
    CommunityRepository(adapter: GetIt.I.get<CommunityDataSource>()),
  );

  GetIt.I.registerSingleton<UserService2>(
    UserService2(
      authRepository: GetIt.I.get<IAuthRepository>(),
      userRepository: GetIt.I.get<DatabaseService2<String, User>>(),
    ),
  );
  GetIt.I.registerSingleton<CommunityService>(
    CommunityService(
      adapter: GetIt.I.get<DatabaseService2<String, CommunityDto>>(),
      fileRepository: GetIt.I.get<FileRepository>(),
    ),
  );

  GetIt.I.registerSingleton(
    NewCommunityGroupPageViewModel(
      communityService: GetIt.I.get<CommunityService>(),
      userService: GetIt.I.get<UserService2>(),
    ),
  );

  GetIt.I.registerFactory<CommunityViewModel>(
    () => CommunityViewModel(
      communitiesRepository: GetIt.I.get<CommunityService>(),
    ),
  );
  GetIt.I.registerFactory<ProfilePageViewModel>(
    () => ProfilePageViewModel(userService: GetIt.I.get<UserService2>()),
  );
  GetIt.I.registerFactory<AuthViewModel>(
    () => AuthViewModel(userService: GetIt.I.get<UserService2>()),
  );
  GetIt.I.registerFactory<NewCommunityViewModel>(
    () => NewCommunityViewModel(
      communitiesRepository: GetIt.I<CommunityService>(),
    ),
  );

  GetIt.I.registerFactory<NewEventViewModel>(
    () => NewEventViewModel(
      eventService: GetIt.I.get<EventService>(),
      communitiesRepository: GetIt.I<CommunityService>(),
    ),
  );
  GetIt.I.registerFactory<EventsViewModel>(
    () => EventsViewModel(eventService: GetIt.I<EventService>()),
  );

  var logindata = await GetIt.I.get<UserService2>().loadLogindataLocally();
  user;
  if (logindata != null) {
    user = await GetIt.I.get<UserService2>().login(
      UserCredentials(email: logindata.name, password: logindata.password),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GetIt.I.get<EventsViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetIt.I.get<NewCommunityViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetIt.I<CommunityViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetIt.I<NewEventViewModel>(),
        ),
        ChangeNotifierProvider(create: (context) => GetIt.I<AuthViewModel>()),
        ChangeNotifierProvider(
          create: (context) => GetIt.I<ProfilePageViewModel>(),
        ),
        ChangeNotifierProvider(
          create: (context) => GetIt.I<NewCommunityGroupPageViewModel>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: user == null ? const AuthPage() : HomePage(indexTab: 0),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
