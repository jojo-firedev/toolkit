import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_toolkit/services/router.dart';
import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';

void main() {
  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FireDevToolkitApp());
}

class FireDevToolkitApp extends StatelessWidget {
  const FireDevToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: 'FD Toolkit',
        primaryColor:
            Theme.of(context).primaryColor.value, // This line is required
      ),
    );

    return MaterialApp.router(
      title: 'FD Toolkit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
