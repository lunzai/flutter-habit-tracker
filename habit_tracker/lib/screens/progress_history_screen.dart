import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/progress_provider.dart';
import '../widgets/progress_card.dart';

class ProgressHistoryScreen extends StatefulWidget {
  final Habit habit;

  const ProgressHistoryScreen({super.key, required this.habit});

  @override
  State<ProgressHistoryScreen> createState() => _ProgressHistoryScreenState();
}

class _ProgressHistoryScreenState extends State<ProgressHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    return Provider.of<ProgressProvider>(context, listen: false)
        .loadProgress(widget.habit.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress History'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            if (progressProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final progressList = progressProvider.getProgressForHabit(widget.habit.id!);

            if (progressList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text('No progress recorded yet.'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: progressList.length + 1,
              itemBuilder: (context, index) {
                if (index == progressList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Swipe left to delete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final progress = progressList[index];
                return ProgressCard(
                  progress: progress,
                  habit: widget.habit,
                );
              },
            );
          },
        ),
      ),
    );
  }
} 