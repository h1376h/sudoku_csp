import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_csp/sudoku_solver.dart';

void main() {
  late SudokuSolver solver;

  setUp(() {
    solver = SudokuSolver();
  });

  group('SudokuSolver Initialization', () {
    test('should initialize with empty grid', () {
      expect(solver.grid.length, 9);
      expect(solver.grid[0].length, 9);
      expect(
          solver.grid.expand((row) => row).every((cell) => cell == null), true);
    });

    test('should initialize with full domains', () {
      final expectedDomain = {1, 2, 3, 4, 5, 6, 7, 8, 9};
      expect(solver.domains.length, 9);
      expect(solver.domains[0].length, 9);
      expect(
        solver.domains
            .expand((row) => row)
            .every((domain) => domain == expectedDomain),
        true,
      );
    });
  });

  group('Cell Updates', () {
    test('should update cell and domains correctly', () {
      solver.updateCell(0, 0, 5);

      // Check if cell was updated
      expect(solver.grid[0][0], 5);

      // Check if domain was updated for the cell
      expect(solver.domains[0][0], {5});

      // Check if value was removed from related cells' domains
      // Row check
      expect(solver.domains[0][1].contains(5), false);
      // Column check
      expect(solver.domains[1][0].contains(5), false);
      // Box check
      expect(solver.domains[1][1].contains(5), false);
    });

    test('should reset cell and recalculate domains', () {
      // Set initial value
      solver.updateCell(0, 0, 5);

      // Reset cell
      solver.updateCell(0, 0, null);

      // Check if cell was reset
      expect(solver.grid[0][0], null);

      // Check if domain was restored
      expect(solver.domains[0][0], {1, 2, 3, 4, 5, 6, 7, 8, 9});
    });
  });

  group('Solving Steps', () {
    test('should perform forward checking correctly', () {
      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: false,
        useLCV: false,
        useDegree: false,
      );

      expect(result.success, true);
      expect(result.explanation.isNotEmpty, true);
    });

    test('should detect violations with forward checking', () {
      // Create a situation that will cause a violation
      solver.updateCell(0, 0, 5);
      solver.updateCell(0, 1, 5);

      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: false,
        useLCV: false,
        useDegree: false,
      );

      expect(result.success, false);
      expect(result.explanation.contains('violation'), true);
    });
  });

  group('Backtracking', () {
    test('should backtrack correctly', () {
      // Make some moves first
      solver.solveStep(
        isForwardChecking: true,
        useMRV: false,
        useLCV: false,
        useDegree: false,
      );

      final result = solver.backtrack();

      expect(result.success, true);
      expect(result.explanation.contains('Backtracked'), true);
    });

    test('should handle empty backtrack stack', () {
      final result = solver.backtrack();

      expect(result.success, false);
      expect(result.explanation, 'No moves to backtrack from!');
    });
  });

  group('Heuristics', () {
    test('should use MRV correctly', () {
      // Setup a grid where one cell has fewer options
      solver.updateCell(0, 0, 1);
      solver.updateCell(0, 1, 2);
      solver.updateCell(0, 2, 3);

      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: true,
        useLCV: false,
        useDegree: false,
      );

      expect(result.success, true);
    });

    test('should use LCV correctly', () {
      final result = solver.solveStep(
        isForwardChecking: true,
        useMRV: false,
        useLCV: true,
        useDegree: false,
      );

      expect(result.success, true);
    });
  });
}
