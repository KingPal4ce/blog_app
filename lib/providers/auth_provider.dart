import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/services/auth_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _status = _service.currentSession != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    _currentUser = _service.currentUser;
    _authSubscription = _service.onAuthStateChange.listen(
      _handleAuthStateChange,
    );
  }

  final AuthService _service;
  late final StreamSubscription<AuthState> _authSubscription;

  late AuthStatus _status;
  User? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;

  User? get currentUser => _currentUser;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  bool get isLoading => _status == AuthStatus.authenticating;

  Future<bool> register({
    required String email,
    required String password,
  }) {
    return _run(() => _service.signUp(email: email, password: password));
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<void> logout() => _service.signOut();

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<AuthResponse> Function() action) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void _handleAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.initialSession:
        final Session? session = state.session;
        if (session != null) {
          _status = AuthStatus.authenticated;
          _currentUser = session.user;
          notifyListeners();
          if (state.event == AuthChangeEvent.signedIn) {
            unawaited(_service.ensureUserProfile(session.user));
          }
        }
        break;
      case AuthChangeEvent.signedOut:
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    unawaited(_authSubscription.cancel());
    super.dispose();
  }
}
