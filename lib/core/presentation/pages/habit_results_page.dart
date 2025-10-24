import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit/habit_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../bloc/habit/habit_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';
class HabitResultsPage extends StatefulWidget {
  const HabitResultsPage({super.key});
  @override
  State<HabitResultsPage> createState() => _HabitResultsPageState();
}
class _HabitResultsPageState extends State<HabitResultsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Habit Results'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitLoading) {
            return const LoadingWidget(message: 'Loading results...');
          } else if (state is HabitFailure) {
            return CustomErrorWidget(
              title: 'Failed to load results',
              message: state.message,
              onRetry: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  context.read<HabitBloc>().add(LoadUserHabits(authState.user.id!));
                }
              },
            );
          } else if (state is HabitSuccess) {
            return _buildResultsContent(state.habits);
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
  Widget _buildResultsContent(List<dynamic> habits) {
    if (habits.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.analytics_outlined,
        title: 'No habits yet',
        subtitle: 'Create your first habit to see results here',
        showButton: false,
      );
    }
    final totalHabits = habits.length;
    final activeHabits = habits.where((habit) => habit.isActive).length;
    final completedToday = habits.where((habit) {
      return habit.lastCompletedAt != null &&
          DateTime.now().difference(habit.lastCompletedAt).inDays == 0;
    }).length;
    final totalStreakDays = habits.fold<int>(0, (sum, habit) => sum + habit.currentStreak as int);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep building those habits!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Habits',
                      value: '$totalHabits',
                      icon: Icons.fitness_center,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Active Habits',
                      value: '$activeHabits',
                      icon: Icons.play_circle,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Completed Today',
                      value: '$completedToday',
                      icon: Icons.check_circle,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Total Streaks',
                      value: '$totalStreakDays',
                      icon: Icons.local_fire_department,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  completedToday > 0 ? Icons.celebration : Icons.emoji_events_outlined,
                  color: completedToday > 0 ? Colors.orange : Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  completedToday > 0 
                      ? 'Great job today!'
                      : 'Ready to start?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  completedToday > 0
                      ? 'You completed $completedToday habit${completedToday == 1 ? '' : 's'} today!'
                      : 'Complete your first habit to see progress here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}