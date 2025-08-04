import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_graph/social_graph_page/cubit/social_graph_page_cubit.dart';
import 'package:social_graph/social_graph_page/social_graph_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => SocialGraphPageCubit(),
        child: const SocialGraphPage(),
      ),
    );
  }
}
