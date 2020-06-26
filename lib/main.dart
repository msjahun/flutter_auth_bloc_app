import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterapp/authentication_bloc/authentication_bloc.dart';
import 'package:flutterapp/home_screen.dart';
import 'package:flutterapp/login/login_screen.dart';
import 'package:flutterapp/simple_bloc_delegate.dart';
import 'package:flutterapp/splash_screen.dart';
import 'package:flutterapp/userRepository.dart';

enum CounterEvent { increment, decrement }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AuthenticationStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationInitial) {
            return SplashScreen();
          }
          if (state is AuthenticationFailure) {
            return LoginScreen(
              userRepository: _userRepository,
            );
          }
          if (state is AuthenticationSuccess) {
            return HomeScreen(name: state.displayName);
          }
          return Container();
        },
      ),
    );
  }
}
