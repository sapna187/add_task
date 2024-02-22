


import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseInitializationProvider = FutureProvider((ref) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer(
        builder: (context, watch, child) {
          final AsyncValue<dynamic> firebaseInitializationState = ref.watch(firebaseInitializationProvider);
          return firebaseInitializationState.when(
            data: (_) => LoginPage(),
            loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (error, stackTrace) => Scaffold(
              body: Center(child: Text('Firebase initialization error')),
            ),
          );
        },
      ),
    );
  }
}
