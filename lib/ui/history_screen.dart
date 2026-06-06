import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/exercise.dart';
import '../models/weight_unit.dart';
import '../utils/formulas.dart';
import 'app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.exerciseName,
    required this.assetPath,
    required this.records,
    required this.unit,
  });

  final String exerciseName;
  final String assetPath;
  final List<ExerciseRecord> records;
  final WeightUnit unit;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<ExerciseRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.records);
  }

  void _delete(ExerciseRecord record) async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete entry?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${formatWeight(record.weight, widget.unit, 0)} × ${record.reps} reps\n'
          '1RM: ${formatWeight(record.oneRM, widget.unit)}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _records.remove(record);
      });
    }
  }

  void _back() {
    Navigator.of(context).pop(_records);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<ExerciseRecord>.from(_records)
      ..sort((a, b) => b.date.compareTo(a.date));

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
                widget.assetPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.accent,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text('${widget.exerciseName} History'),
            ],
          ),
        ),
        body: sorted.isEmpty
            ? Center(
                child: Text(
                  'No records yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final record = sorted[index];
                  return _buildEntry(context, record);
                },
              ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, ExerciseRecord record) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () => _delete(record),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatWeight(record.weight, widget.unit)} × ${record.reps} reps',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1RM: ${formatWeight(record.oneRM, widget.unit)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.textMuted,
                    onPressed: () => _delete(record),
                    tooltip: 'Delete',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}
