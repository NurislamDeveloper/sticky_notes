import 'package:flutter/material.dart';
import '../cards/app_card.dart';
import '../layouts/section_header.dart';
import '../../../constants/app_colors.dart';

class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;
  final Widget? action;

  const FormSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
    this.padding,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            action: action,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
