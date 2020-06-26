import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutterapp/login/bloc/login_bloc.dart';
import 'package:flutterapp/userRepository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;

  LoginBloc({
    @required UserRepository userRepository,
  })
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LoginState get initialState => LoginState.initial();

  @override
  Stream<Transition<LoginEvent, LoginState>> transformEvents(
      Stream<LoginEvent> events,
      TransitionFunction<LoginEvent, LoginState> transitionFn,) {
    final nonDebounceStream = events.where((event) {
      return (event is! LoginEmailChanged && event is! LoginPasswordChanged);
    });

    final debounceStream = events.where((event) {
      return (event is LoginEmailChanged || event is LoginPasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEmailChanged) {
      yield* _mapLoginEmailChangedToState(event.email);
    } else if (event is LoginPasswordChanged) {
      yield* _mapLoginPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<LoginState> _mapLoginEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapLoginPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _userRepository.signInWithGoogle();
      yield LoginState.success();

    } catch (e) {
      print('google auth');
      print(e);
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithCredentials(email, password);
      yield LoginState.success();
    } catch (e) {
      yield LoginState.failure();
    }
  }
}


class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPassword(String password) {
  //  return _passwordRegExp.hasMatch(password);
    return true;
  }
}
