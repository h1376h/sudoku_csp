import 'app_texts.dart';

class SudokuSolver {
  List<List<int?>> grid;
  List<List<Set<int>>> domains;
  List<List<bool>> isInitialValue;
  int? currentRow;
  int? currentCol;
  List<List<Set<int>>> savedDomains = [];
  bool needsBacktrack = false;
  final List<(int row, int col, int value, Set<int> remaining)> moveHistory =
      [];

  SudokuSolver()
      : grid = List.generate(9, (_) => List.filled(9, null)),
        domains = List.generate(
          9,
          (_) => List.generate(9, (_) => {1, 2, 3, 4, 5, 6, 7, 8, 9}),
        ),
        isInitialValue = List.generate(9, (_) => List.filled(9, false));

  void updateCell(int row, int col, int? value) {
    grid[row][col] = value;
    isInitialValue[row][col] = value != null;
    if (value != null) {
      domains[row][col] = {value};
      _updateDomains(row, col, value);
    } else {
      _resetDomain(row, col);
    }
  }

  void _updateDomains(int row, int col, int value) {
    // Remove value from row domains
    for (int c = 0; c < 9; c++) {
      if (c != col) domains[row][c].remove(value);
    }

    // Remove value from column domains
    for (int r = 0; r < 9; r++) {
      if (r != row) domains[r][col].remove(value);
    }

    // Remove value from 3x3 box domains
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row || c != col) domains[r][c].remove(value);
      }
    }
  }

  void _resetDomain(int row, int col) {
    domains[row][col] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    // Recalculate domain based on existing values
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] != null) domains[row][col].remove(grid[row][i]);
      if (grid[i][col] != null) domains[row][col].remove(grid[i][col]);
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] != null) domains[row][col].remove(grid[r][c]);
      }
    }
  }

  StepResult solveStep({
    required bool isForwardChecking,
    required bool useMRV,
    required bool useLCV,
    required bool useDegree,
  }) {
    if (currentRow == null && currentCol == null) {
      needsBacktrack = false;
    }

    if (needsBacktrack) {
      return StepResult(
        success: false,
        explanation: AppTexts.useBacktrackButton,
      );
    }

    if (isComplete()) {
      return StepResult(
        success: true,
        explanation: AppTexts.puzzleSolved,
      );
    }

    final nextCell = _findNextCell(useMRV, useDegree);
    if (nextCell == null) {
      needsBacktrack = true;
      return StepResult(
        success: false,
        explanation: AppTexts.noValidCells,
      );
    }

    final (row, col) = nextCell;
    currentRow = row;
    currentCol = col;

    // Get available values for this cell
    final availableValues = useLCV
        ? _getOrderedValuesByLCV(Set<int>.from(domains[row][col]))
        : domains[row][col].toList();

    if (availableValues.isEmpty) {
      needsBacktrack = true;
      return StepResult(
        success: false,
        explanation: AppTexts.noValidValues
            .replaceAll('{0}', '${row + 1}')
            .replaceAll('{1}', '${col + 1}'),
        variable: 'Cell (${row + 1}, ${col + 1})',
        domain: domains[row][col],
        constraintsViolated: 'No valid values available.',
      );
    }

    // Store all domain information before making any changes
    final savedDomains = _copyDomains();

    // Try the first available value
    final value = availableValues.first;
    final remainingValues = Set<int>.from(domains[row][col])..remove(value);
    moveHistory.add((row, col, value, remainingValues));

    grid[row][col] = value;

    if (isForwardChecking) {
      _updateDomains(row, col, value);

      if (!_forwardCheck()) {
        // Restore domains to their state before this move
        domains = savedDomains;
        grid[row][col] = null;
        needsBacktrack = true;
        return StepResult(
          success: false,
          explanation: AppTexts.forwardCheckingViolation
              .replaceAll('{0}', '${row + 1}')
              .replaceAll('{1}', '${col + 1}')
              .replaceAll('{2}', '$value'),
          variable: 'Cell (${row + 1}, ${col + 1})',
          domain: domains[row][col],
          constraintsViolated: AppTexts.forwardCheckingViolationDetails,
        );
      }
    } else {
      if (!_isValid(row, col)) {
        grid[row][col] = null;
        needsBacktrack = true;

        // Determine which specific constraint is violated
        final violatedConstraint = _getViolatedConstraint(row, col, value);

        return StepResult(
          success: false,
          explanation: AppTexts.valueViolatesConstraints
              .replaceAll('{0}', '$value')
              .replaceAll('{1}', '${row + 1}')
              .replaceAll('{2}', '${col + 1}')
              .replaceAll('{3}', violatedConstraint.constraint),
          variable: 'Cell (${row + 1}, ${col + 1})',
          domain: domains[row][col],
          constraintsViolated: violatedConstraint.details,
        );
      }
    }

    return StepResult(
      success: true,
      explanation: AppTexts.placedValue
          .replaceAll('{0}', '$value')
          .replaceAll('{1}', '${row + 1}')
          .replaceAll('{2}', '${col + 1}'),
      variable: 'Cell (${row + 1}, ${col + 1})',
      domain: domains[row][col],
    );
  }

  StepResult backtrack() {
    if (moveHistory.isEmpty) {
      return StepResult(
        success: false,
        explanation: AppTexts.noMovesToBacktrack,
      );
    }

    final (row, col, oldValue, remainingValues) = moveHistory.removeLast();

    // Remove the old value from the grid
    grid[row][col] = null;

    // Reset domains for the entire grid
    _resetAllDomains();

    // Update domains based on current grid state
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] != null) {
          _updateDomains(r, c, grid[r][c]!);
        }
      }
    }

    // Set the remaining values for the current cell
    domains[row][col] = remainingValues;

    needsBacktrack = false;
    currentRow = row;
    currentCol = col;

    return StepResult(
      success: true,
      explanation: AppTexts.backtracked
          .replaceAll('{0}', '$oldValue')
          .replaceAll('{1}', '${row + 1}')
          .replaceAll('{2}', '${col + 1}'),
      variable: 'Cell (${row + 1}, ${col + 1})',
      domain: domains[row][col],
      constraintsViolated: 'Backtracked from value $oldValue.',
    );
  }

  void _resetAllDomains() {
    domains = List.generate(
      9,
      (_) => List.generate(9, (_) => {1, 2, 3, 4, 5, 6, 7, 8, 9}),
    );
  }

  bool _isValid(int row, int col) {
    final value = grid[row][col];
    if (value == null) return true;

    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && grid[row][c] == value) return false;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && grid[r][col] == value) return false;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && grid[r][c] == value) return false;
      }
    }

    return true;
  }

  List<int> _getOrderedValuesByLCV(Set<int> domain) {
    return domain.toList()
      ..sort((a, b) => _countConstraints(a).compareTo(_countConstraints(b)));
  }

  int _countConstraints(int value) {
    var count = 0;
    final row = currentRow!;
    final col = currentCol!;

    // Count how many domains would be affected in row, column and box
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == null && domains[row][i].contains(value)) count++;
      if (grid[i][col] == null && domains[i][col].contains(value)) count++;
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == null && domains[r][c].contains(value)) count++;
      }
    }

    return count;
  }

  List<List<Set<int>>> _copyDomains() {
    return domains
        .map((row) => row.map((domain) => Set<int>.from(domain)).toList())
        .toList();
  }

  bool isComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == null) return false;
      }
    }
    return true;
  }

  (int, int)? _findNextCell(bool useMRV, bool useDegree) {
    if (!useMRV) {
      // Simple left-to-right, top-to-bottom search
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (grid[r][c] == null) return (r, c);
        }
      }
      return null;
    }

    // Minimum Remaining Values heuristic
    var minDomain = 10;
    var maxDegree = -1;
    List<(int, int)> minCells = [];

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == null) {
          final domainSize = domains[r][c].length;

          if (domainSize < minDomain) {
            minDomain = domainSize;
            minCells = [(r, c)];
            if (useDegree) maxDegree = _countUnassignedNeighbors(r, c);
          } else if (domainSize == minDomain) {
            if (useDegree) {
              final degree = _countUnassignedNeighbors(r, c);
              if (degree > maxDegree) {
                maxDegree = degree;
                minCells = [(r, c)];
              } else if (degree == maxDegree) {
                minCells.add((r, c));
              }
            } else {
              minCells.add((r, c));
            }
          }
        }
      }
    }

    return minCells.isEmpty ? null : minCells.first;
  }

  void reset() {
    grid = List.generate(9, (_) => List.filled(9, null));
    domains = List.generate(
      9,
      (_) => List.generate(9, (_) => {1, 2, 3, 4, 5, 6, 7, 8, 9}),
    );
    // Reset isInitialValue tracking
    isInitialValue = List.generate(9, (_) => List.filled(9, false));
    // Reset state variables
    currentRow = null;
    currentCol = null;
    needsBacktrack = false;
    moveHistory.clear();
    savedDomains.clear();
  }

  void initializeWithSamplePuzzle() {
    reset();
    final samplePuzzle = [
      [5, 3, null, null, 7, null, null, null, null],
      [6, null, null, 1, 9, 5, null, null, null],
      [null, 9, 8, null, null, null, null, 6, null],
      [8, null, null, null, 6, null, null, null, 3],
      [4, null, null, 8, null, 3, null, null, 1],
      [7, null, null, null, 2, null, null, null, 6],
      [null, 6, null, null, null, null, 2, 8, null],
      [null, null, null, 4, 1, 9, null, null, 5],
      [null, null, null, null, 8, null, null, 7, 9],
    ];

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        grid[row][col] = samplePuzzle[row][col];
        // Mark sample puzzle values as initial
        isInitialValue[row][col] = samplePuzzle[row][col] != null;
      }
    }

    // Reset domains and update them based on initial values
    domains = List.generate(
        9, (_) => List.generate(9, (_) => {1, 2, 3, 4, 5, 6, 7, 8, 9}));
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] != null) {
          domains[row][col] = {grid[row][col]!};
          _updateDomains(row, col, grid[row][col]!);
        }
      }
    }
  }

  bool _forwardCheck() {
    // Create a deep copy of domains before making changes
    final tempDomains = _copyDomains();

    final value = grid[currentRow!][currentCol!];
    if (value == null) return true;

    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != currentCol && grid[currentRow!][c] == null) {
        tempDomains[currentRow!][c].remove(value);
        if (tempDomains[currentRow!][c].isEmpty) {
          return false;
        }
      }
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != currentRow && grid[r][currentCol!] == null) {
        tempDomains[r][currentCol!].remove(value);
        if (tempDomains[r][currentCol!].isEmpty) {
          return false;
        }
      }
    }

    // Check 3x3 box
    final boxRow = (currentRow! ~/ 3) * 3;
    final boxCol = (currentCol! ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != currentRow || c != currentCol) && grid[r][c] == null) {
          tempDomains[r][c].remove(value);
          if (tempDomains[r][c].isEmpty) {
            return false;
          }
        }
      }
    }

    // If we reach here, the forward check passed, so update the actual domains
    domains = tempDomains;
    return true;
  }

  ({String constraint, String details}) _getViolatedConstraint(
    int row,
    int col,
    int value,
  ) {
    // Check row constraint
    for (int c = 0; c < 9; c++) {
      if (c != col && grid[row][c] == value) {
        return (
          constraint: AppTexts.rowConstraint,
          details: AppTexts.rowConstraintViolation
              .replaceAll('{0}', '$value')
              .replaceAll('{1}', '${row + 1}'),
        );
      }
    }

    // Check column constraint
    for (int r = 0; r < 9; r++) {
      if (r != row && grid[r][col] == value) {
        return (
          constraint: AppTexts.columnConstraint,
          details: AppTexts.columnConstraintViolation
              .replaceAll('{0}', '$value')
              .replaceAll('{1}', '${col + 1}'),
        );
      }
    }

    // Check 3x3 box constraint
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && grid[r][c] == value) {
          return (
            constraint: AppTexts.boxConstraint,
            details: AppTexts.boxConstraintViolation
                .replaceAll('{0}', '$value')
                .replaceAll('{1}', '${row + 1}')
                .replaceAll('{2}', '${col + 1}'),
          );
        }
      }
    }

    return (constraint: 'Unknown', details: 'Unknown constraint violation');
  }

  int _countUnassignedNeighbors(int row, int col) {
    var weightedCount = 0;

    void processCell(int r, int c) {
      if (grid[r][c] == null) {
        // Give more weight to cells with smaller domains
        weightedCount += (10 - domains[r][c].length);
      }
    }

    // Process row, column, and box cells with weighted counting
    for (int c = 0; c < 9; c++) {
      if (c != col) processCell(row, c);
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && grid[r][c] == null) processCell(r, c);
      }
    }

    // Return weighted count instead of raw count
    return weightedCount;
  }
}

class StepResult {
  final bool success;
  final String explanation;
  final String? variable; // e.g., "Cell (1,1)"
  final Set<int>? domain; // e.g., {1, 2, 3}
  final String? constraintsViolated; // e.g., "Row Constraint"

  StepResult({
    required this.success,
    required this.explanation,
    this.variable,
    this.domain,
    this.constraintsViolated,
  });
}
