import 'package:flutter/material.dart';
import '../models/birthday.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import 'minimal_card.dart';

class BirthdayCard extends StatelessWidget {
  final Birthday birthday;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWish;
  final VoidCallback? onShare;

  const BirthdayCard({
    super.key,
    required this.birthday,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onWish,
    this.onShare,
  });

  String _getStatusText() {
    if (birthday.daysUntil == 0) return "Today!";
    if (birthday.daysUntil == 1) return "Tomorrow";
    return "In ${birthday.daysUntil} days";
  }

  Color _getStatusColor() {
    if (birthday.daysUntil == 0) return AppTheme.primaryColor;
    if (birthday.daysUntil == 1) return AppTheme.secondaryColor;
    return AppTheme.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Semantics(
      label: '${birthday.name}, turns ${birthday.age} on ${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}, ${_getStatusText()}',
      button: true,
      child: MinimalCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: _buildAvatar(),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      birthday.name,
                      style: AppTheme.heading3(isDark).copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        const Icon(
                          Icons.cake_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          "Turns ${birthday.age}",
                          style: AppTheme.bodySmall(isDark),
                        ),
                        const SizedBox(width: AppTheme.spacingMD),
                        Icon(
                          Icons.card_giftcard_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          _getStatusText(),
                          style: AppTheme.bodySmall(isDark).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      "${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}",
                      style: AppTheme.bodySmall(isDark).copyWith(
                        color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 18, color: AppTheme.textPrimary),
                          const SizedBox(width: AppTheme.spacingSM),
                          Text('Edit', style: AppTheme.bodyMedium(isDark)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onEdit!,
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded, size: 18, color: AppTheme.errorColor),
                          const SizedBox(width: AppTheme.spacingSM),
                          Text(
                            'Delete',
                            style: AppTheme.bodyMedium(isDark).copyWith(color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onDelete!,
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Quick Actions
          if (birthday.daysUntil <= 7) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWish,
                    icon: const Icon(Icons.message_rounded, size: 16),
                    label: const Text('Wish'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                      side: BorderSide.none,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                      side: BorderSide.none,
                      backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildAvatar() {
    Widget avatarWidget;
    
    if (birthday.photo != null) {
      // Check if it's a local file path or URL
      if (birthday.photo!.startsWith('http')) {
        avatarWidget = CachedNetworkImage(
          imageUrl: birthday.photo!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 56,
            height: 56,
            color: AppTheme.backgroundLight,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(),
        );
      } else {
        // Local file
        avatarWidget = Image.file(
          File(birthday.photo!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
        );
      }
    } else {
      avatarWidget = _buildAvatarFallback();
    }
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: avatarWidget,
    );
  }

  Widget _buildAvatarFallback() {
    final initials = birthday.name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('')
        .toUpperCase()
        .substring(0, birthday.name.split(' ').length > 1 ? 2 : 1);
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.heading3(false).copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
