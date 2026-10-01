import 'package:flutter/material.dart';

import 'data/api/api_client.dart';
import 'data/repositories/characters_repository.dart';
import 'screens/characters_screen.dart';

void main() {
  final repository = CharactersRepository(createApiClient());
  runApp(CharactersApp(repository: repository));
}

class CharactersApp extends StatelessWidget {
  const CharactersApp({super.key, required this.repository});

  final CharactersRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick and Morty',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: CharactersScreen(repository: repository),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF97CE4C), // «портальный» зелёный
        brightness: brightness,
      ),
    );
  }
}
