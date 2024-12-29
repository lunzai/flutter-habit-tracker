import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalActionController;
  late TextEditingController _goalCountController;
  late TextEditingController _goalUnitController;
  late int _goalRepeat;
  late String _goalRepeatInterval;
  late bool _goalHasExpectedEndDate;
  late DateTime? _goalExpectedEndDate;
  late String _progressType;
  late TextEditingController _progressStepController;
  bool _isLoading = false;
  late bool _isRepeatingHabit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _goalActionController = TextEditingController(text: widget.habit.goalAction);
    _goalCountController = TextEditingController(text: widget.habit.goalCount.toString());
    _goalUnitController = TextEditingController(text: widget.habit.goalUnit);
    _goalRepeat = widget.habit.goalRepeat;
    _isRepeatingHabit = widget.habit.goalRepeat > 0;
    _goalRepeatInterval = widget.habit.goalRepeatInterval;
    _goalHasExpectedEndDate = widget.habit.goalHasExpectedEndDate;
    _goalExpectedEndDate = widget.habit.goalExpectedEndDate;
    _progressType = widget.habit.progressType;
    _progressStepController = TextEditingController(text: widget.habit.progressStep.toString());
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedHabit = Habit(
        id: widget.habit.id,
        title: _titleController.text,
        description: _descriptionController.text,
        goalAction: _goalActionController.text,
        goalCount: double.parse(_goalCountController.text),
        goalUnit: _goalUnitController.text,
        goalRepeat: _goalRepeat,
        goalRepeatInterval: _goalRepeatInterval,
        goalHasExpectedEndDate: _goalHasExpectedEndDate,
        goalExpectedEndDate: _goalExpectedEndDate,
        progressType: _progressType,
        progressStep: double.parse(_progressStepController.text),
        createdAt: widget.habit.createdAt,
        updatedAt: DateTime.now(),
      );

      try {
        await Provider.of<HabitProvider>(context, listen: false)
            .updateHabit(updatedHabit);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Habit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _goalActionController,
                decoration: const InputDecoration(
                  labelText: 'What do you want to achieve?',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _goalCountController,
                decoration: const InputDecoration(labelText: 'Goal Value'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _goalUnitController,
                decoration: const InputDecoration(labelText: 'Goal Unit'),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Repeating Habit'),
                value: _isRepeatingHabit,
                onChanged: (value) {
                  setState(() {
                    _isRepeatingHabit = value;
                    _goalRepeat = value ? 1 : 0;
                  });
                },
              ),
              if (_isRepeatingHabit) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _goalRepeat,
                        decoration: const InputDecoration(labelText: 'How many?'),
                        items: List.generate(7, (i) => i + 1).map((i) {
                          return DropdownMenuItem(value: i, child: Text('$i'));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _goalRepeat = value ?? 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _goalRepeatInterval,
                        decoration: const InputDecoration(labelText: 'Interval'),
                        items: ['day', 'week', 'month'].map((interval) {
                          return DropdownMenuItem(value: interval, child: Text(interval));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _goalRepeatInterval = value ?? 'day');
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Set end date?'),
                value: _goalHasExpectedEndDate,
                onChanged: (value) {
                  setState(() => _goalHasExpectedEndDate = value);
                },
              ),
              if (_goalHasExpectedEndDate)
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _goalExpectedEndDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() => _goalExpectedEndDate = date);
                      }
                    },
                    child: Text(_goalExpectedEndDate != null
                        ? _goalExpectedEndDate!.toString().split(' ')[0]
                        : 'Select Date'),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Steps Towards Goal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _progressType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  DropdownMenuItem(value: 'increment', child: Text('Step Up / Gaining / Improve')),
                  DropdownMenuItem(value: 'decrement', child: Text('Step Down / Losing / Quit')),
                ].toList(),
                onChanged: (value) {
                  setState(() => _progressType = value ?? 'increment');
                },
              ),
              TextFormField(
                controller: _progressStepController,
                decoration: const InputDecoration(labelText: 'Default Interval'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveHabit,
                        child: const Text('Save Changes'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalActionController.dispose();
    _goalCountController.dispose();
    _goalUnitController.dispose();
    _progressStepController.dispose();
    super.dispose();
  }
} 