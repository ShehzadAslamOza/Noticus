import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noticus/core/utils/StreamController.dart';

// Core
import 'package:noticus/core/widgets/splash_page.dart';

// Features - Auth
import 'package:noticus/features/auth/bloc/auth_bloc.dart';
import 'package:noticus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:noticus/features/auth/data/sources/firebase_auth_service.dart';
import 'package:noticus/features/auth/domain/usecases/login_usecase.dart';
import 'package:noticus/features/auth/domain/usecases/signup_usecase.dart';

// Features - Notification Listener
import 'package:noticus/features/notification_listner/bloc/notification_listner_bloc.dart';
import 'package:noticus/features/notification_listner/data/repositories/notification_repository_impl.dart';
import 'package:noticus/features/notification_listner/data/sources/notification_service.dart';

// Features - History
import 'package:noticus/features/history/bloc/history_bloc.dart';
import 'package:noticus/features/history/domain/usecases/fetch_history_usecase.dart';
import 'package:noticus/features/history/data/repositories/history_repository_impl.dart';
import 'package:noticus/features/history/data/sources/history_remote_data_source.dart';
import 'package:torch_controller/torch_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  TorchController().initialize();

  // Initialize repositories and services
  final authRepository = AuthRepositoryImpl(
    firebaseAuthService: FirebaseAuthService(),
  );

  final historyRepository = HistoryRepositoryImpl(
    remoteDataSource: HistoryRemoteDataSource(
      firestore: FirebaseFirestore.instance,
    ),
  );

  final notificationRepository = NotificationRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    notificationService: NotificationService(),
  );

  runApp(MyApp(
    authRepository: authRepository,
    notificationRepository: notificationRepository,
    historyRepository: historyRepository,
  ));

  WidgetsBinding.instance.addObserver(LifecycleEventHandler(
    onAppExit: () => NotificationEventBus().dispose(),
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final NotificationRepositoryImpl notificationRepository;
  final HistoryRepositoryImpl historyRepository;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.notificationRepository,
    required this.historyRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(authRepository),
            signupUseCase: SignupUseCase(authRepository),
          ),
        ),

        // NotificationListenerBloc
        BlocProvider<NotificationListenerBloc>(
          create: (_) => NotificationListenerBloc(
            startListener: (userId) =>
                notificationRepository.startNotificationListener(userId),
            stopListener: () =>
                notificationRepository.stopNotificationListener(),
          ),
        ),

        // HistoryBloc
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            fetchHistory: FetchHistoryUseCase(historyRepository),
          ),
        ),

        // RulesBloc
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Notification Manager App",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashPage(),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final void Function()? onAppExit;

  LifecycleEventHandler({this.onAppExit});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onAppExit?.call();
    }
  }
}
