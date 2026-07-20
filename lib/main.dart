import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:blog_app/app/app.dart';
import 'package:blog_app/app/router.dart';
import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final AuthProvider authProvider = AuthProvider(AuthService());
  final GoRouter router = buildRouter(authProvider);

  runApp(
    MultiProvider(
      providers: <ChangeNotifierProvider<AuthProvider>>[
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: App(router: router),
    ),
  );
}
