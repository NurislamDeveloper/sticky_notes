import 'package:flutter/material.dart';
import '../widgets/collapsible_widgets.dart';
import '../../constants/app_strings.dart';
import '../../config/app_config.dart';
class HabitInfoPage extends StatelessWidget {
  const HabitInfoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(AppStrings.habitGuide),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            CollapsibleSection(
              title: 'Atomic Habits Principles',
              icon: Icons.science,
              initiallyExpanded: false,
              content: _buildAtomicHabitsSection(),
            ),
            CollapsibleSection(
              title: 'Habit Formation Process',
              icon: Icons.trending_up,
              content: _buildHabitFormationSection(),
            ),
            CollapsibleSection(
              title: 'Pro Tips & Strategies',
              icon: Icons.lightbulb,
              content: _buildTipsSection(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            'Master Your Habits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn the science behind building lasting habits',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAtomicHabitsSection() {
    return _buildInfoCard(
      title: 'Atomic Habits Principles',
      icon: Icons.auto_awesome,
      color: const Color(0xFF10B981),
      children: [
        _buildInfoItem(
          '1% Better Every Day',
          'Small improvements compound into remarkable results over time',
          Icons.trending_up,
        ),
        _buildInfoItem(
          'Systems Over Goals',
          'Focus on the process, not just the outcome',
          Icons.settings,
        ),
        _buildInfoItem(
          'Identity-Based Habits',
          'Change who you are, not just what you do',
          Icons.person_outline,
        ),
        _buildInfoItem(
          'Environment Design',
          'Make good habits obvious and bad habits invisible',
          Icons.home_outlined,
        ),
      ],
    );
  }
  Widget _buildHabitFormationSection() {
    return _buildInfoCard(
      title: 'The Habit Loop',
      icon: Icons.refresh,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildInfoItem(
          'Cue',
          'The trigger that starts your habit',
          Icons.flag_outlined,
        ),
        _buildInfoItem(
          'Craving',
          'The motivation behind the habit',
          Icons.favorite_outline,
        ),
        _buildInfoItem(
          'Response',
          'The actual habit you perform',
          Icons.play_circle_outline,
        ),
        _buildInfoItem(
          'Reward',
          'The benefit you gain from the habit',
          Icons.star_outline,
        ),
      ],
    );
  }
  Widget _buildTipsSection() {
    return _buildInfoCard(
      title: 'Pro Tips',
      icon: Icons.tips_and_updates,
      color: const Color(0xFFF59E0B),
      children: [
        _buildInfoItem(
          'Start Small',
          'Begin with habits so easy you can\'t say no',
          Icons.play_arrow,
        ),
        _buildInfoItem(
          'Stack Habits',
          'Link new habits to existing ones',
          Icons.link,
        ),
        _buildInfoItem(
          'Track Progress',
          'What gets measured gets managed',
          Icons.analytics_outlined,
        ),
        _buildInfoItem(
          'Be Patient',
          'Habits take time to form - stay consistent',
          Icons.schedule,
        ),
      ],
    );
  }
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}