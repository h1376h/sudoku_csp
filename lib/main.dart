import 'package:flutter/material.dart';
import 'package:sudoku_csp/app_texts.dart';

import 'sudoku_solver_screen.dart';

void main() {
  runApp(const SudokuSolverApp());
}

class SudokuSolverApp extends StatelessWidget {
  const SudokuSolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppTexts.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      ),
      home: const SudokuSolverScreen(),
    );
  }
}
