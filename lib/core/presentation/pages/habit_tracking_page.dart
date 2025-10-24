import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/habit/habit_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../bloc/habit/habit_state.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/collapsible_widgets.dart';
import '../../constants/app_strings.dart';
import '../../config/app_config.dart';
import 'create_habit_page.dart';
import 'habit_results_page.dart';
import 'habit_info_page.dart';
import 'notification_settings_page.dart';
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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                      if (authState.user.id != null) _buildProfilePage(authState.user.id!) else const Center(child: Text('User ID not available')),
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
              _pageController.jumpToPage(index);
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
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
      ),
      ),
    );
  }
  Widget _buildHabitsPage(int userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(LoadUserHabits(userId));
    });
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(AppStrings.myHabits),
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
            body: BlocListener<HabitBloc, HabitState>(
              listener: (context, state) {
                if (state is HabitDeleted) {
                  context.read<HabitBloc>().add(LoadUserHabits(userId));
                }
              },
              child: BlocBuilder<HabitBloc, HabitState>(
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
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => CreateHabitPage(userId: userId),
            ),
          );
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
  Widget _buildProfilePage(int userId) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileCard(state.user),
                  CollapsibleSection(
                    title: 'User Details',
                    icon: Icons.info,
                    content: _buildUserInfoCard(state.user),
                  ),
                  CollapsibleSection(
                    title: 'Account Information',
                    icon: Icons.account_circle,
                    content: _buildAccountInfoCard(state.user),
                  ),
                  CollapsibleSection(
                    title: 'Notification Settings',
                    icon: Icons.notifications,
                    content: _buildNotificationSettingsCard(context, state.user.id!),
                  ),
                  CollapsibleSection(
                    title: 'Account Actions',
                    icon: Icons.logout,
                    content: _buildLogoutCard(context),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Widget _buildHabitsList(BuildContext context, List<dynamic> habits) {
    if (habits.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.fitness_center,
        title: 'No habits yet',
        subtitle: 'Create your first habit to start tracking your progress',
        buttonText: 'Create First Habit',
        showButton: true,
        onButtonPressed: () async {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthSuccess && authState.user.id != null) {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => CreateHabitPage(userId: authState.user.id!),
              ),
            );
            if (result == true) {
              context.read<HabitBloc>().add(LoadUserHabits(authState.user.id!));
            }
          }
        },
      );
    }
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              child: SearchBarWidget(
                hintText: 'Search habits...',
                onChanged: (value) {
                  if (habits.isNotEmpty) {
                    context.read<HabitBloc>().add(SearchHabits(habits.first.userId, value));
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text(
                                        habit.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${habit.currentStreak}/${habit.targetDays} days',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showDeleteHabitDialog(context, habit),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                tooltip: 'Delete habit',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  habit.description,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        habit.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    _buildCompleteButton(context, habit),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
  Widget _buildProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
            child: _buildAvatarImage(user.avatarPath),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _changeAvatar(context, user.id!),
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text('Change Avatar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildUserInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('User ID', user.id?.toString() ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Username', user.username),
          const SizedBox(height: 12),
          _buildInfoRow('Email', user.email),
        ],
      ),
    );
  }
  Widget _buildAccountInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Account Created', '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
          const SizedBox(height: 12),
          _buildInfoRow('Last Login', user.lastLoginAt != null 
              ? '${user.lastLoginAt!.day}/${user.lastLoginAt!.month}/${user.lastLoginAt!.year}'
              : 'Never'),
          const SizedBox(height: 12),
          _buildInfoRow('Avatar Status', _getAvatarStatus(user.avatarPath)),
        ],
      ),
    );
  }
  Widget _buildNotificationSettingsCard(BuildContext context, int userId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage(userId: userId),
                  ),
                );
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Notification Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _getAvatarStatus(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return 'Default Avatar';
    }
    final File avatarFile = File(avatarPath);
    if (!avatarFile.existsSync()) {
      return 'Avatar File Missing';
    }
    return 'Custom Avatar Set';
  }
  Widget _buildAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const Icon(
        Icons.person,
        size: 80,
        color: Color(0xFF1E3A8A),
      );
    }
    final File avatarFile = File(avatarPath);
    if (!avatarFile.existsSync()) {
      return const Icon(
        Icons.person,
        size: 80,
        color: Color(0xFF1E3A8A),
      );
    }
    return ClipOval(
      child: Image.file(
        avatarFile,
        width: 160,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.person,
            size: 80,
            color: Color(0xFF1E3A8A),
          );
        },
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Future<void> _changeAvatar(BuildContext context, int userId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 80,
      );
      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_$userId.jpg';
        final String avatarPath = '${appDir.path}/$fileName';
        final File avatarFile = File(avatarPath);
        if (avatarFile.existsSync()) {
          await avatarFile.delete();
        }
        await avatarFile.writeAsBytes(await image.readAsBytes());
        if (avatarFile.existsSync()) {
          context.read<AuthBloc>().add(UpdateAvatarRequested(
            userId: userId,
            avatarPath: avatarPath,
          ));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Avatar updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception('Failed to save avatar file');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Failed to update avatar: $e'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  Widget _buildCompleteButton(BuildContext context, dynamic habit) {
    final today = DateTime.now();
    final lastCompleted = habit.lastCompletedAt;
    final isCompletedToday = lastCompleted != null &&
        lastCompleted.year == today.year &&
        lastCompleted.month == today.month &&
        lastCompleted.day == today.day;
    if (isCompletedToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text(
              'Completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: () => _showCompleteHabitDialog(context, habit),
      icon: const Icon(Icons.check, size: 14),
      label: const Text('Complete'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(0, 32),
      ),
    );
  }
  void _showDeleteHabitDialog(BuildContext context, dynamic habit) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete "${habit.title}"'),
          content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                                        context.read<HabitBloc>().add(DeleteHabit(habit.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Habit deleted successfully'),
                          ],
                        ),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
