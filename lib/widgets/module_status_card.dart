import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/enums.dart';

class ModuleStatusCard extends StatelessWidget {
  const ModuleStatusCard({
    super.key,
    required this.title,
    required this.status,
    this.icon,
    this.onTap,
  });

  final String title;
  final ModuleStatus status;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.extension,
                  color: _getIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${status.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getStatusTextColor(),
                          ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    switch (status) {
      case ModuleStatus.completed:
        return AppColors.success.withValues(alpha: 0.3);
      case ModuleStatus.failed:
        return AppColors.error.withValues(alpha: 0.3);
      case ModuleStatus.pending:
      case ModuleStatus.notStarted:
        return AppColors.divider;
    }
  }

  Color _getIconBackgroundColor() {
    switch (status) {
      case ModuleStatus.completed:
        return AppColors.success.withValues(alpha: 0.1);
      case ModuleStatus.failed:
        return AppColors.error.withValues(alpha: 0.1);
      case ModuleStatus.pending:
      case ModuleStatus.notStarted:
        return AppColors.neutralLight;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case ModuleStatus.completed:
        return AppColors.success;
      case ModuleStatus.failed:
        return AppColors.error;
      case ModuleStatus.pending:
      case ModuleStatus.notStarted:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case ModuleStatus.completed:
        return AppColors.success;
      case ModuleStatus.failed:
        return AppColors.error;
      case ModuleStatus.pending:
      case ModuleStatus.notStarted:
        return AppColors.textSecondary;
    }
  }
}
