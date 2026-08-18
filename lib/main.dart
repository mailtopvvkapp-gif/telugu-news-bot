import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'news_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://trjtwtktmudviqjasiat.supabase.co',
    anonKey: 'sb_secret_sC7ya-fAcIybjG6Vh801CA_mlHM0rG5',
  );

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Regional News',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const NewsHomeScreen(),
    );
  }
}
