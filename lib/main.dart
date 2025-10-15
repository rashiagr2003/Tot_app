import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Add this import
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tot_app/models/dog_model.dart';
import 'package:tot_app/models/journey_model.dart';

import 'adapters/providers/dog_provider.dart';
import 'adapters/providers/location_provider.dart';
import 'tracking/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // optional: allows upside-down portrait
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(DogModelAdapter());
  Hive.registerAdapter(JourneyModelAdapter());
  Hive.registerAdapter(LocationPointAdapter());
  await Hive.openBox<DogModel>('dogs');
  await Hive.openBox<JourneyModel>('journeys');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DogProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'TOT APP',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            elevation: 4,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
