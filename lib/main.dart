import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/firebase_options.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/auth_page.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/repositories/events_repository.dart';
import 'package:meet_christ/repositories/file_repository.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:meet_christ/services/group_service.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/auth/cubit/auth_cubit.dart';
import 'package:meet_christ/view_models/auth_view_model.dart';
import 'package:meet_christ/view_models/chat_list_view_model.dart';
import 'package:meet_christ/view_models/community_view_model.dart';
import 'package:meet_christ/view_models/event_comments_view_model.dart';
import 'package:meet_christ/view_models/event_detail_view_model.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:meet_christ/view_models/new_community_group_view_model.dart';
import 'package:meet_christ/view_models/new_community_view_model.dart';
import 'package:meet_christ/view_models/new_event_view_model.dart';
import 'package:meet_christ/view_models/profile_view_model.dart';
import 'package:meet_christ/view_models/signup/signup_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

User? user;
void main() async {
  final i = GetIt.I;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  var factory = BackendAuthFactory(type: BackendType.firestore);
  GetIt.I.registerSingleton<IAuthRepository>(factory.getRepository());
  GetIt.I.registerSingleton<FileRepository>(FileRepository());
  GetIt.I.registerSingleton<DatabaseService2<String, User>>(
    FirestoreUserRepository(),
  );
  GetIt.I.registerSingleton<UserService>(
    UserService(
      authRepository: GetIt.I.get<IAuthRepository>(),
      userRepository: GetIt.I.get<DatabaseService2<String, User>>(),
    ),
  );
  GetIt.I.registerSingleton<IEventRepository>(
    FirestoreEventRepository(GetIt.I.get<DatabaseService2<String, User>>()),
  );

  GetIt.I.registerSingleton<CommentService>(CommentService());
  GetIt.I.registerSingleton<IGroupRepository>(FirestoreGroupRepository());
  GetIt.I.registerSingleton<GroupService>(
    GroupService(GetIt.I.get<IGroupRepository>()),
  );

  GetIt.I.registerSingleton<EventService>(
    EventService(GetIt.I.get<IEventRepository>(), GetIt.I.get<UserService>()),
  );

  GetIt.I.registerSingleton<EventCommentsService>(
    EventCommentsService(userService: GetIt.I.get<UserService>()),
  );

  GetIt.I.registerSingleton<ICommunityRepository>(
    FirestoreCommunityRepository(),
  );

  GetIt.I.registerSingleton<CommunityService>(
    CommunityService(GetIt.I.get<ICommunityRepository>()),
  );

  GetIt.I.registerSingleton(
    NewCommunityGroupPageViewModel(
      groupService: GetIt.I.get<GroupService>(),
      userService: GetIt.I.get<UserService>(),
    ),
  );

  GetIt.I.registerFactory<CommunityViewModel>(
    () => CommunityViewModel(
      userService: GetIt.I.get<UserService>(),
      communitiesRepository: GetIt.I.get<CommunityService>(),
      groupService: GetIt.I.get<GroupService>(),
    ),
  );

  GetIt.I.registerFactory<ConnectivityViewModel>(() => ConnectivityViewModel());

  GetIt.I.registerFactory<EventDetailViewModel>(
    () => EventDetailViewModel(
      userService: GetIt.I.get<UserService>(),
      eventService: GetIt.I.get<EventService>(),
    ),
  );

  GetIt.I.registerFactory<SignupBloc>(() => SignupBloc());

  GetIt.I.registerFactory<ProfilePageViewModel>(
    () => ProfilePageViewModel(userService: GetIt.I.get<UserService>()),
  );
  GetIt.I.registerFactory<AuthViewModel>(
    () => AuthViewModel(userService: GetIt.I.get<UserService>()),
  );
  GetIt.I.registerFactory<NewCommunityViewModel>(
    () => NewCommunityViewModel(
      communitiesRepository: GetIt.I<CommunityService>(),
    ),
  );

  GetIt.I.registerFactory<EventCommentsViewModel>(
    () => EventCommentsViewModel(eventService: GetIt.I<EventCommentsService>()),
  );

  GetIt.I.registerFactory<NewEventViewModel>(
    () => NewEventViewModel(
      eventService: GetIt.I.get<EventService>(),
      communitiesRepository: GetIt.I<CommunityService>(),
      userService: GetIt.I.get<UserService>(),
    ),
  );
  GetIt.I.registerFactory<ChatListViewModel>(() => ChatListViewModel());

  GetIt.I.registerFactory<EventsViewModel>(
    () => EventsViewModel(
      userService: GetIt.I.get<UserService>(),
      eventService: GetIt.I<EventService>(),
      communityService: GetIt.I<CommunityService>(),
    ),
  );

  /*  var user = await GetIt.I.get<UserService>().login(
      UserCredentials(email: "szindl@posteo.de", password: "Jesus1000."),
    );

    await GetIt.I.get<UserService>().saveUserdataLocally(
      LoginData(name: "szindl@posteo.de", password: "Jesus1000."),
    );
*/

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignupBloc()),
        BlocProvider(create: (context) => AuthCubit(userService: GetIt.I.get<UserService>())),
      ],
      child: MultiProvider(
        providers: [
          // add signup bloc provider
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
          ChangeNotifierProvider(
            create: (context) => GetIt.I<EventDetailViewModel>(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetIt.I<ConnectivityViewModel>(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetIt.I<EventCommentsViewModel>(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetIt.I<ChatListViewModel>(),
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
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meet Christ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
      builder: (context, child) =>
          Stack(children: [child!, ConnectivityBanner()]),
    );
  }
}
