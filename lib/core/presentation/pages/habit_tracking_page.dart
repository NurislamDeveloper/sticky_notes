import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection/injection_container.dart' as di;
import '../bloc/auth/auth_bloc.dart';
import '../bloc/habit/habit_bloc.dart';
import '../widgets/habit_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'create_habit_page.dart';
import 'habit_results_page.dart';
import 'habit_info_page.dart';

class HabitTrackingPage extends StatefulWidget {
  const HabitTrackingPage({super.key});

  @override
  State<HabitTrackingPage> createState() => _HabitTrackingPageState();
}

class _HabitTrackingPageState extends State<HabitTrackingPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthSuccess) {
              return PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  if (authState.user.id != null) _buildHabitsPage(authState.user.id!) else const Center(child: Text('User ID not available')),
                  const HabitResultsPage(),
                  const HabitInfoPage(),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'My Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Habit Info',
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsPage(int userId) {
    // Load user's habits when the page is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always load habits to ensure we have the latest data
      context.read<HabitBloc>().add(LoadUserHabits(userId));
    });
    
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('My Habits'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          if (state is HabitLoading) {
            return const LoadingWidget(message: 'Loading habits...');
          } else if (state is HabitSuccess) {
            return _buildHabitsList(context, state.habits);
          } else if (state is HabitFailure) {
            return CustomErrorWidget(
              title: 'Failed to load habits',
              message: state.message,
              onRetry: () {
                context.read<HabitBloc>().add(LoadUserHabits(userId));
              },
            );
          } else {
            return const LoadingWidget();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => CreateHabitPage(userId: userId),
            ),
          );
          
          // If habit was created, refresh the habits list
          if (result == true) {
            context.read<HabitBloc>().add(LoadUserHabits(userId));
          }
        },
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }

  Widget _buildHabitsList(BuildContext context, List<dynamic> habits) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first habit to start tracking your progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess && authState.user.id != null) {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateHabitPage(userId: authState.user.id!),
                    ),
                  );
                  
                  // If habit was created, refresh the habits list
                  if (result == true) {
                    context.read<HabitBloc>().add(LoadUserHabits(authState.user.id!));
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Habit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(16),
          child: SearchBarWidget(
            hintText: 'Search habits...',
            onChanged: (value) {
              // Trigger search when user types in the search field
              if (habits.isNotEmpty) {
                context.read<HabitBloc>().add(SearchHabits(habits.first.userId, value));
              }
            },
          ),
        ),
        // Habits List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (habits.isNotEmpty) {
                context.read<HabitBloc>().add(LoadUserHabits(habits.first.userId));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(
                  habit: habit,
                  onTap: () => _showCompleteHabitDialog(context, habit),
                );
              },
            ),
          ),
        ),
      ],
    );
  }


  String _getStreakStatus(dynamic habit) {
    final daysSinceCreated = DateTime.now().difference(habit.createdAt).inDays;
    final completionRate = daysSinceCreated > 0 ? habit.currentStreak / daysSinceCreated : 0.0;
    
    if (completionRate >= 0.8) return 'excellent';
    if (completionRate >= 0.6) return 'good';
    if (completionRate >= 0.3) return 'needs_work';
    return 'just_started';
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'water_drop':
        return Icons.water_drop;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      default:
        return Icons.fitness_center;
    }
  }

  void _showCompleteHabitDialog(BuildContext context, dynamic habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Complete Habit'),
          ],
        ),
        content: Text(
          'Did you complete "${habit.title}" today?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HabitBloc>().add(CompleteHabit(habit.id));
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Habit completed! Great job!'),
                    ],
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              const Text('Sign Out'),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                final authBloc = context.read<AuthBloc>();
                final navigator = Navigator.of(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Successfully signed out'),
                      ],
                    ),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );

                Future.delayed(const Duration(milliseconds: 500), () {
                  authBloc.add(SignOutRequested());
                  navigator.pushReplacementNamed('/auth');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
