import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'edit_habit_screen.dart';
import 'add_progress_screen.dart';
import 'progress_history_screen.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Basic Information',
              [
                _buildDetailRow('Title', habit.title),
                if (habit.description?.isNotEmpty ?? false)
                  _buildDetailRow('Description', habit.description!),
                _buildDetailRow('Created', _formatDate(habit.createdAt)),
                _buildDetailRow('Last Updated', _formatDate(habit.updatedAt)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Goal Details',
              [
                _buildDetailRow('Action', habit.goalAction),
                _buildDetailRow('Target', '${habit.goalCount} ${habit.goalUnit}'),
                if (habit.goalRepeat > 0) ...[
                  _buildDetailRow(
                    'Frequency',
                    '${habit.goalRepeat} times per ${habit.goalRepeatInterval}',
                  ),
                ],
                if (habit.goalHasExpectedEndDate && habit.goalExpectedEndDate != null)
                  _buildDetailRow(
                    'Expected End Date',
                    _formatDate(habit.goalExpectedEndDate!),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Progress Settings',
              [
                _buildDetailRow(
                  'Type',
                  habit.progressType == 'increment'
                      ? 'Step Up / Gaining / Improve'
                      : 'Step Down / Losing / Quit',
                ),
                _buildDetailRow('Default Step', habit.progressStep.toString()),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProgressScreen(habit: habit),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressHistoryScreen(habit: habit),
                ),
              );
            },
            child: const Text('View Progress History'),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<HabitProvider>(context, listen: false)
            .deleteHabit(habit.id);
        if (context.mounted) {
          Navigator.of(context).pop(); // Return to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting habit: ${e.toString()}')),
          );
        }
      }
    }
  }
} 