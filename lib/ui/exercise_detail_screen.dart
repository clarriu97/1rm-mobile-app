import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/default_exercises.dart';
import '../models/exercise.dart';
import '../utils/formulas.dart';
import 'add_entry_screen.dart';
import 'app_theme.dart';
import 'history_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.template,
    required this.records,
  });

  final ExerciseTemplate template;
  final List<ExerciseRecord> records;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late List<ExerciseRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.records);
  }

  double? get _bestOneRM {
    if (_records.isEmpty) return null;
    return _records.map((r) => r.oneRM).reduce((a, b) => a > b ? a : b);
  }

  ExerciseRecord? get _latestEntry {
    if (_records.isEmpty) return null;
    return _records.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  Future<void> _addEntry() async {
    final record = await Navigator.of(context).push<ExerciseRecord>(
      MaterialPageRoute<ExerciseRecord>(
        builder: (context) => AddEntryScreen(
          exerciseName: widget.template.name,
          assetPath: widget.template.assetPath,
        ),
      ),
    );

    if (record != null) {
      setState(() {
        _records.add(record);
      });
    }
  }

  Future<void> _openHistory() async {
    final updatedRecords = await Navigator.of(context)
        .push<List<ExerciseRecord>>(
          MaterialPageRoute<List<ExerciseRecord>>(
            builder: (context) => HistoryScreen(
              exerciseName: widget.template.name,
              assetPath: widget.template.assetPath,
              records: _records,
            ),
          ),
        );

    if (updatedRecords != null) {
      setState(() {
        _records = updatedRecords;
      });
    }
  }

  void _back() {
    Navigator.of(context).pop(_records);
  }

  @override
  Widget build(BuildContext context) {
    final best = _bestOneRM;
    final latest = _latestEntry;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _back,
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                widget.template.assetPath,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.template.name),
            ],
          ),
          actions: [
            if (_records.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'History',
                onPressed: _openHistory,
              ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (best != null) ...[
                    const SizedBox(height: 8),
                    _buildBestOneRM(context, best, latest),
                    const SizedBox(height: 24),
                    _buildPercentageTable(context, best),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 40),
                    _buildEmptyState(context),
                  ],
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addEntry,
          backgroundColor: AppColors.cta,
          foregroundColor: AppColors.background,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Entry'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildBestOneRM(
    BuildContext context,
    double best,
    ExerciseRecord? latest,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cta.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Best 1RM',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: AppColors.cta,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${best.toStringAsFixed(1)} kg',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.cta,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (latest != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Latest: ${latest.weight.toStringAsFixed(1)} kg × ${latest.reps} reps → ${latest.oneRM.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPercentageTable(BuildContext context, double best) {
    final table = generatePercentageTable(best);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Working weights', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(60),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [_buildTableHeader(), ...table.map(_buildTableRow)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface.withAlpha(100)),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Percentage',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Weight',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(PercentageEntry entry) {
    final isHundred = entry.percentage == 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.textMuted.withAlpha(20), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${entry.percentage}%',
              style: TextStyle(
                color: isHundred ? AppColors.cta : AppColors.textPrimary,
                fontWeight: isHundred ? FontWeight.w700 : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${entry.weight.toStringAsFixed(1)} kg',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isHundred ? AppColors.cta : AppColors.textPrimary,
                fontWeight: isHundred ? FontWeight.w700 : FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              widget.template.assetPath,
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppColors.accent.withAlpha(100),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No records yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap "Add Entry" to log your first\ntraining data for this exercise.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
