import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'features/splash/presentation/views/splash_screen.dart';
import 'features/auth/presentation/views/auth_screen.dart';

void main() async {
  flutter.WidgetsFlutterBinding.ensureInitialized();

  // Set app to full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  Stripe.publishableKey =
      'pk_test_51Sg57h66OTAIXnY80vLEdVFGA4ahQdaFhDbHn64Mu0hNnZrCBlyINV0Dwavo2xhBUpGgDLnqLjteJiORVWqnnxHX00N2YAMup5';
  await Stripe.instance.applySettings();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  flutter.runApp(const MyApp());
}

class MyApp extends flutter.StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.MaterialApp(
      title: 'UnderStore',
      debugShowCheckedModeBanner: false,
      theme: flutter.ThemeData(
        brightness: flutter.Brightness.dark,
        scaffoldBackgroundColor: const flutter.Color(0xFF0A0E21),
        colorScheme: flutter.ColorScheme.dark(
          primary: const flutter.Color(0xFF5145FC),
          secondary: const flutter.Color(0xFF8B5CF6),
          surface: const flutter.Color(0xFF1A1F3A),
        ),
        cardColor: const flutter.Color(0xFF1A1F3A),
        appBarTheme: const flutter.AppBarTheme(
          backgroundColor: flutter.Color(0xFF0A0E21),
          elevation: 0,
        ),
      ),
      home: SplashScreen(nextScreen: AuthScreen()),
    );
  }
}

class MyHomePage extends flutter.StatefulWidget {
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
  flutter.State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends flutter.State<MyHomePage> {
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
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      appBar: flutter.AppBar(
        backgroundColor: flutter.Theme.of(context).colorScheme.inversePrimary,
        title: flutter.Text(widget.title),
      ),
      body: flutter.Center(
        child: flutter.Column(
          mainAxisAlignment: flutter.MainAxisAlignment.center,
          children: <flutter.Widget>[
            const flutter.Text('You have pushed the button this many times:'),
            flutter.Text(
              '$_counter',
              style: flutter.Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: flutter.FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const flutter.Icon(flutter.Icons.add),
      ),
    );
  }
}
