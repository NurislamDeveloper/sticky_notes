import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_bloc.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_event.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_state.dart';
import 'package:noteflow/core/services/simple_notification_service.dart';
import 'package:noteflow/core/presentation/widgets/collapsible_widgets.dart';
import 'package:noteflow/core/constants/app_strings.dart';
import 'package:noteflow/core/config/app_config.dart';
class NotificationSettingsPage extends StatefulWidget {
  final int userId;
  const NotificationSettingsPage({super.key, required this.userId});
  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}
class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotificationSettings(widget.userId));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notificationSettings),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationSuccess || state is NotificationUpdated) {
            final settings = state is NotificationSuccess 
                ? state.settings 
                : (state as NotificationUpdated).settings;
            return _buildSettingsContent(settings);
          }
          if (state is NotificationFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(LoadNotificationSettings(widget.userId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  Widget _buildSettingsContent(settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollapsibleSection(
            title: 'General Settings',
            icon: Icons.settings,
            initiallyExpanded: true,
            content: Column(
              children: [
                _buildSwitchTile(
                  title: 'Enable Notifications',
                  subtitle: 'Allow the app to send you notifications',
                  value: settings.isEnabled,
                  onChanged: (value) {
                    context.read<NotificationBloc>().add(ToggleNotificationEnabled(value));
                  },
                ),
                const Divider(),
                _buildTimeTile(
                  title: 'Daily Reminder Time',
                  subtitle: 'When to send daily habit reminders',
                  time: _parseTime(settings.reminderTime),
                  onTap: () => _selectTime(context, settings),
                ),
              ],
            ),
          ),
          CollapsibleSection(
            title: 'Notification Types',
            icon: Icons.notifications,
            content: Column(
              children: [
                _buildSwitchTile(
                  title: 'Daily Reminders',
                  subtitle: 'Get reminded to check your habits daily',
                  value: settings.dailyReminders,
                  onChanged: settings.isEnabled ? (value) {
                    context.read<NotificationBloc>().add(ToggleDailyReminders(value));
                  } : null,
                ),
                const Divider(),
                _buildSwitchTile(
                  title: 'Weekly Reports',
                  subtitle: 'Receive weekly progress summaries',
                  value: settings.weeklyReports,
                  onChanged: settings.isEnabled ? (value) {
                    context.read<NotificationBloc>().add(ToggleWeeklyReports(value));
                  } : null,
                ),
                const Divider(),
                _buildSwitchTile(
                  title: 'Streak Reminders',
                  subtitle: 'Get notified about your habit streaks',
                  value: settings.streakReminders,
                  onChanged: settings.isEnabled ? (value) {
                    context.read<NotificationBloc>().add(ToggleStreakReminders(value));
                  } : null,
                ),
                const Divider(),
                _buildSwitchTile(
                  title: 'Achievement Notifications',
                  subtitle: 'Celebrate your milestones and achievements',
                  value: settings.achievementNotifications,
                  onChanged: settings.isEnabled ? (value) {
                    context.read<NotificationBloc>().add(ToggleAchievementNotifications(value));
                  } : null,
                ),
              ],
            ),
          ),
          CollapsibleSection(
            title: 'Test Notifications',
            icon: Icons.bug_report,
            content: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Test Now'),
                  subtitle: const Text('Show notification immediately'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _testNotificationNow(context),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Test Scheduled (10 seconds)'),
                  subtitle: const Text('Test if scheduled notifications work'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _testScheduledNotification(context),
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Test 1 Minute'),
                  subtitle: const Text('Close app and wait 1 minute'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _testOneMinute(context),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Check Status'),
                  subtitle: const Text('See scheduled notifications in console'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _checkStatus(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF1E3A8A),
    );
  }
  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  Future<void> _selectTime(BuildContext context, settings) async {
    final currentTime = _parseTime(settings.reminderTime);
    print('Opening time picker with current time: ${currentTime.hour}:${currentTime.minute}');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    print('Time picker result: ${picked?.hour}:${picked?.minute}');
    if (picked != null && mounted) {
      final timeChanged = picked.hour != currentTime.hour || picked.minute != currentTime.minute;
      print('Time changed: $timeChanged');
      if (timeChanged) {
        final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        print('Updating time to: $timeString');
        context.read<NotificationBloc>().add(UpdateReminderTime(timeString));
      }
    }
  }
  Future<void> _testNotificationNow(BuildContext context) async {
    try {
      final notificationService = SimpleNotificationService();
      await notificationService.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification should appear now!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _testScheduledNotification(BuildContext context) async {
    try {
      final notificationService = SimpleNotificationService();
      await notificationService.scheduleTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification scheduled for 10 seconds!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _testOneMinute(BuildContext context) async {
    try {
      final notificationService = SimpleNotificationService();
      await notificationService.scheduleOneMinuteTest();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test scheduled for 1 minute! Close app and wait.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _checkStatus(BuildContext context) async {
    try {
      final notificationService = SimpleNotificationService();
      await notificationService.checkNotificationStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status checked! Check console for details.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
