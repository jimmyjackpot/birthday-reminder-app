import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/birthday.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAnniversary = birthday.eventType == EventType.anniversary;
    final reminderCount = birthday.getReminderCount();

    return Semantics(
      label:
          '${birthday.name}, turns ${birthday.age} on ${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}, ${_getStatusText()}',
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.surface(isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow(isDark),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Section: Avatar and Title Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Avatar with Notification Bell Overlay
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildAvatar(isDark),
                          // Notification Bell Overlay (yellow/orange)
                          if (birthday.reminderEnabled && reminderCount > 0)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor, // Yellow/Amber
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.surface(isDark),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  PhosphorIcons.bell(PhosphorIconsStyle.fill),
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: AppTheme.spacingMD),

                      // Title and Badge Section - Use Expanded to prevent overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title and Badge in a Wrap to handle overflow
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Flexible(
                                  child: Text(
                                    birthday.name,
                                    style: AppTheme.heading3(isDark).copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurface(isDark),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Event Type Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAnniversary
                                        ? AppTheme.secondaryColor.withValues(
                                            alpha:
                                                0.2) // Light teal for anniversary
                                        : AppTheme.primaryColor.withValues(
                                            alpha:
                                                0.2), // Light pink for birthday
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAnniversary
                                            ? PhosphorIcons.heart(
                                                PhosphorIconsStyle.fill)
                                            : PhosphorIcons.cake(
                                                PhosphorIconsStyle.fill),
                                        size: 12,
                                        color: isAnniversary
                                            ? AppTheme.secondaryColor // Teal
                                            : AppTheme.primaryColor, // Pink
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAnniversary
                                            ? 'Anniversary'
                                            : 'Birthday',
                                        style: AppTheme.labelSmall(isDark)
                                            .copyWith(
                                          color: isAnniversary
                                              ? AppTheme.secondaryColor // Teal
                                              : AppTheme.primaryColor, // Pink
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingMD),

                  // Details Section - Use proper layout instead of fixed padding
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spacer to align with avatar (64px avatar + 16px spacing = 80px)
                      const SizedBox(width: 64 + AppTheme.spacingMD),
                      // Details content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Birthday: "Turns X" with cake icon OR Anniversary: "In X days" with gift icon
                            if (!isAnniversary) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIcons.cake(
                                        PhosphorIconsStyle.regular),
                                    size: 16,
                                    color: AppTheme.onSurface(isDark),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Turns ${birthday.age}',
                                      style:
                                          AppTheme.bodyMedium(isDark).copyWith(
                                        color: AppTheme.onSurface(isDark),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                            ],

                            // "In X days" with gift box icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.gift(
                                      PhosphorIconsStyle.regular),
                                  size: 16,
                                  color: AppTheme.onSurface(isDark),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _getStatusText(),
                                    style: AppTheme.bodyMedium(isDark).copyWith(
                                      color: AppTheme.onSurface(isDark),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacingXS),

                            // Date
                            Text(
                              "${_getMonthName(birthday.birthdate.month)} ${birthday.birthdate.day}",
                              style: AppTheme.bodySmall(isDark).copyWith(
                                color: AppTheme.onSurfaceVariant(isDark),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Reminder Count (if enabled)
                            if (birthday.reminderEnabled &&
                                reminderCount > 0) ...[
                              const SizedBox(height: AppTheme.spacingXS),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    PhosphorIcons.bell(
                                        PhosphorIconsStyle.regular),
                                    size: 14,
                                    color: AppTheme.secondaryColor, // Teal
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "$reminderCount reminder${reminderCount != 1 ? 's' : ''}",
                                      style:
                                          AppTheme.bodySmall(isDark).copyWith(
                                        color: AppTheme.secondaryColor, // Teal
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingLG),

                  // Bottom Section: Wish and Share Buttons - Make responsive
                  Row(
                    children: [
                      // Send Wish Button: Pink background with white text
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 44,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor, // Pink
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onWish,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingSM + 2,
                                  horizontal: AppTheme.spacingSM,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIcons.chatCircle(
                                          PhosphorIconsStyle.regular),
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Send Wish',
                                        style: AppTheme.labelMedium(isDark)
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: AppTheme.spacingMD),

                      // Share Button: Teal background with white text
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 44,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor, // Teal
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onShare,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingSM + 2,
                                  horizontal: AppTheme.spacingSM,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIcons.share(
                                          PhosphorIconsStyle.regular),
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Share',
                                        style: AppTheme.labelMedium(isDark)
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    Widget avatarWidget;

    if (birthday.photo != null) {
      // Check if it's a local file path or URL
      if (birthday.photo!.startsWith('http')) {
        avatarWidget = CachedNetworkImage(
          imageUrl: birthday.photo!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 64,
            height: 64,
            color: AppTheme.surfaceContainer(isDark),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(isDark),
        );
      } else {
        // Local file
        avatarWidget = Image.file(
          File(birthday.photo!),
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildAvatarFallback(isDark),
        );
      }
    } else {
      avatarWidget = _buildAvatarFallback(isDark);
    }

    return ClipOval(
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: avatarWidget,
      ),
    );
  }

  Widget _buildAvatarFallback(bool isDark) {
    final initials = birthday.name
        .split(' ')
        .map((n) => n.isNotEmpty ? n[0] : '')
        .join('')
        .toUpperCase();

    final displayInitials = initials.length > 2
        ? initials.substring(0, 2)
        : (initials.isEmpty ? '?' : initials);

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayInitials,
          style: AppTheme.heading3(isDark).copyWith(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
