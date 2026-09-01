import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class KrugerXApp extends StatelessWidget {
  const KrugerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KrugerX',
      debugShowCheckedModeBanner: false,
      theme: KrugerXTheme.dark,
      routerConfig: router,
    );
  }
}
