import 'dart:async';

import 'package:flutter/material.dart';

import 'algorithm_controls.dart';
import 'app_texts.dart';
import 'sudoku_grid.dart';
import 'sudoku_solver.dart';

class SudokuSolverScreen extends StatefulWidget {
  const SudokuSolverScreen({super.key});

  @override
  State<SudokuSolverScreen> createState() => _SudokuSolverScreenState();
}

class _SudokuSolverScreenState extends State<SudokuSolverScreen> {
  final SudokuSolver solver = SudokuSolver();
  bool isForwardChecking = true;
  bool useMRV = false;
  bool useLCV = false;
  bool useDegree = false;
  String currentStep = '';
  String currentVariable = '';
  Set<int>? currentDomain;
  String currentConstraintsViolated = '';
  Timer? _solveTimer;
  bool get _isSolving => _solveTimer != null;
  int stepCount = 0;
  static const stepDelay = Duration(microseconds: 10);
  bool _showDomains = false;

  @override
  void dispose() {
    _solveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 1100;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridMaxWidth = screenWidth > 500 ? 500.0 : screenWidth - 32;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          AlgorithmControls(
                            isForwardChecking: isForwardChecking,
                            useMRV: useMRV,
                            useLCV: useLCV,
                            useDegree: useDegree,
                            onAlgorithmChanged: (value) =>
                                setState(() => isForwardChecking = value),
                            onMRVChanged: (value) {
                              setState(() {
                                useMRV = value;
                                if (!value) useDegree = false;
                              });
                            },
                            onLCVChanged: (value) =>
                                setState(() => useLCV = value),
                            onDegreeChanged: (value) =>
                                setState(() => useDegree = value),
                          ),
                          SizedBox(
                            width: gridMaxWidth,
                            child: SudokuGrid(
                              grid: solver.grid,
                              isInitialValue: solver.isInitialValue,
                              domains: solver.domains,
                              showDomains: _showDomains,
                              onCellChanged: (row, col, value) =>
                                  solver.updateCell(row, col, value),
                            ),
                          ),
                          _buildControlButtons(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildExplanationCard(context),
                    ),
                  ],
                )
              : Column(
                  children: [
                    AlgorithmControls(
                      isForwardChecking: isForwardChecking,
                      useMRV: useMRV,
                      useLCV: useLCV,
                      useDegree: useDegree,
                      onAlgorithmChanged: (value) =>
                          setState(() => isForwardChecking = value),
                      onMRVChanged: (value) {
                        setState(() {
                          useMRV = value;
                          if (!value) useDegree = false;
                        });
                      },
                      onLCVChanged: (value) => setState(() => useLCV = value),
                      onDegreeChanged: (value) =>
                          setState(() => useDegree = value),
                    ),
                    Center(
                      child: SizedBox(
                        width: gridMaxWidth,
                        child: SudokuGrid(
                          grid: solver.grid,
                          isInitialValue: solver.isInitialValue,
                          domains: solver.domains,
                          showDomains: _showDomains,
                          onCellChanged: (row, col, value) =>
                              solver.updateCell(row, col, value),
                        ),
                      ),
                    ),
                    _buildControlButtons(),
                    _buildExplanationCard(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentStepExplanation(context),
          const SizedBox(height: 16),
          _buildAlgorithmExplanation(context),
        ],
      ),
    );
  }

  Widget _buildCurrentStepExplanation(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppTexts.currentStepExplanation} (${AppTexts.stepLabel} $stepCount)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              solver.isUnsolvable
                  ? AppTexts.puzzleUnsolvable
                  : currentStep.isEmpty
                      ? AppTexts.welcomeMessage
                      : currentStep,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: solver.isUnsolvable ? Colors.red : null,
                  ),
            ),
            if (currentVariable.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${AppTexts.variableLabel} $currentVariable',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (currentDomain != null) ...[
              const SizedBox(height: 4),
              Text(
                '${AppTexts.domainLabel} ${currentDomain!.isEmpty ? AppTexts.emptyDomain : currentDomain!.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (currentConstraintsViolated.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${AppTexts.constraintsViolatedLabel} $currentConstraintsViolated',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmExplanation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTexts.algorithmDescription,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => _showInfoDialog(context),
              icon: const Icon(Icons.info_outline),
              label: const Text(AppTexts.cspInfo),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _getAlgorithmDescription(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _getAlgorithmDescription() {
    final algorithmContext = isForwardChecking
        ? AppTexts.forwardCheckingContext
        : AppTexts.backtrackingContext;

    final heuristicsContext = [
      if (useMRV) AppTexts.mrvContext,
      if (useDegree && useMRV) AppTexts.degreeContext,
      if (useLCV) AppTexts.lcvContext,
    ].join('\n');

    return '$algorithmContext${heuristicsContext.isNotEmpty ? '\n\n${AppTexts.heuristicsInUse}:$heuristicsContext' : ''}';
  }

  Widget _buildControlButtons() {
    final bool puzzleComplete = solver.isComplete();
    final bool isUnsolvable = solver.isUnsolvable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: (_isSolving || puzzleComplete || isUnsolvable)
                  ? null
                  : solver.needsBacktrack
                      ? _backtrack
                      : _solveStep,
              icon: puzzleComplete
                  ? const Icon(Icons.check_circle)
                  : Icon(solver.needsBacktrack ? Icons.undo : Icons.play_arrow),
              tooltip: puzzleComplete
                  ? AppTexts.puzzleSolved
                  : solver.needsBacktrack
                      ? AppTexts.backtrack
                      : AppTexts.nextStep,
              style: puzzleComplete
                  ? IconButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    )
                  : IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
            ),
            IconButton(
              onPressed:
                  (puzzleComplete || isUnsolvable) ? null : _startSolving,
              icon: _isSolving
                  ? const Icon(Icons.stop)
                  : const Icon(Icons.fast_forward),
              tooltip: _isSolving ? 'Stop' : 'Solve',
              style: _isSolving
                  ? IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    )
                  : null,
            ),
            IconButton(
              onPressed: _isSolving
                  ? null
                  : () {
                      initializeWithSamplePuzzle();
                    },
              icon: const Icon(Icons.refresh),
              tooltip: AppTexts.sample,
            ),
            IconButton(
              onPressed: _isSolving ? null : _resetGrid,
              icon: const Icon(Icons.clear),
              tooltip: AppTexts.reset,
            ),
            Tooltip(
              message: AppTexts.showDomains,
              child: Switch.adaptive(
                activeColor: Theme.of(context).colorScheme.primary,
                value: _showDomains,
                onChanged: (value) {
                  setState(() {
                    _showDomains = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSolving() {
    if (_isSolving) {
      _solveTimer?.cancel();
      _solveTimer = null;
      setState(() {});
      return;
    }

    _solveTimer = Timer.periodic(
      stepDelay,
      (timer) {
        if (solver.isComplete() || solver.isUnsolvable) {
          timer.cancel();
          _solveTimer = null;
          setState(() {});
          return;
        }

        if (solver.needsBacktrack) {
          _backtrack();
        } else {
          _solveStep();
        }
      },
    );
    setState(() {});
  }

  void _solveStep() {
    setState(() {
      final stepResult = solver.solveStep(
        isForwardChecking: isForwardChecking,
        useMRV: useMRV,
        useLCV: useLCV,
        useDegree: useDegree,
      );
      currentStep = stepResult.explanation;
      currentVariable = stepResult.variable ?? '';
      currentDomain = stepResult.domain;
      currentConstraintsViolated = stepResult.constraintsViolated ?? '';
      if (stepResult.success) {
        stepCount++;
        if (solver.isComplete()) {
          currentStep = AppTexts.puzzleSolved;
        }
      }
    });
  }

  void _backtrack() {
    setState(() {
      final stepResult = solver.backtrack();
      currentStep = stepResult.explanation;
      currentVariable = stepResult.variable ?? '';
      currentDomain = stepResult.domain;
      currentConstraintsViolated = stepResult.constraintsViolated ?? '';
      if (stepResult.success) {
        stepCount++;
      }
    });
  }

  void _resetGrid() {
    setState(() {
      solver.reset();
      _resetStateVariables();
    });
  }

  void initializeWithSamplePuzzle() {
    setState(() {
      solver.initializeWithSamplePuzzle();
      _resetStateVariables();
      currentStep = AppTexts.puzzleInitialized;
    });
  }

  void _resetStateVariables() {
    currentStep = '';
    currentVariable = '';
    currentDomain = null;
    currentConstraintsViolated = '';
    stepCount = 0;
    _solveTimer?.cancel();
    _solveTimer = null;
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                AppTexts.formalCspModel,
                AppTexts.formalCspModelContent,
              ),
              _buildInfoSection(
                AppTexts.searchAlgorithms,
                AppTexts.searchAlgorithmsContent,
              ),
              _buildInfoSection(
                AppTexts.heuristicsSection,
                AppTexts.heuristicsContent,
              ),
              _buildInfoSection(
                AppTexts.consistencyChecking,
                AppTexts.consistencyCheckingContent,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppTexts.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
