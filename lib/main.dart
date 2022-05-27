import 'package:flutter/material.dart';
import 'package:cloud/image_view.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await _init();

  runApp(const MyApp());
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ITU ACM SC',
      home: ImageView(),
    );
  }
}
