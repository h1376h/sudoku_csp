import 'package:flutter/material.dart';

import 'app_texts.dart';

class AlgorithmControls extends StatelessWidget {
  final bool isForwardChecking;
  final bool useMRV;
  final bool useLCV;
  final bool useDegree;
  final Function(bool) onAlgorithmChanged;
  final Function(bool) onMRVChanged;
  final Function(bool) onLCVChanged;
  final Function(bool) onDegreeChanged;

  const AlgorithmControls({
    super.key,
    required this.isForwardChecking,
    required this.useMRV,
    required this.useLCV,
    required this.useDegree,
    required this.onAlgorithmChanged,
    required this.onMRVChanged,
    required this.onLCVChanged,
    required this.onDegreeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlgorithmSelector(context),
            const SizedBox(height: 24),
            Text(
              AppTexts.heuristics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildHeuristicSwitch(
              context: context,
              label: AppTexts.mrvTitle,
              subtitle: AppTexts.mrvSubtitle,
              selected: useMRV,
              onChanged: onMRVChanged,
            ),
            _buildHeuristicSwitch(
              context: context,
              label: AppTexts.degreeTitle,
              subtitle: AppTexts.degreeSubtitle,
              selected: useDegree,
              onChanged: useMRV ? onDegreeChanged : null,
            ),
            _buildHeuristicSwitch(
              context: context,
              label: AppTexts.lcvTitle,
              subtitle: AppTexts.lcvSubtitle,
              selected: useLCV,
              onChanged: onLCVChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.algorithm,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<bool>(
          value: isForwardChecking,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: false,
              child: Text(AppTexts.backtracking),
            ),
            DropdownMenuItem(
              value: true,
              child: Text(AppTexts.forwardChecking),
            ),
          ],
          onChanged: (value) => onAlgorithmChanged(value ?? false),
        ),
      ],
    );
  }

  Widget _buildHeuristicSwitch({
    required BuildContext context,
    required String label,
    required String subtitle,
    required bool selected,
    Function(bool)? onChanged,
  }) {
    return SwitchListTile.adaptive(
      activeColor: Theme.of(context).colorScheme.primary,
      title: Text(label),
      subtitle: Text(subtitle),
      value: selected,
      onChanged: onChanged,
    );
  }
}
