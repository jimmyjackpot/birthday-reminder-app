import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/birthday.dart';
import '../theme/app_theme.dart';

class WishDialog extends StatefulWidget {
  final Birthday birthday;

  const WishDialog({super.key, required this.birthday});

  @override
  State<WishDialog> createState() => _WishDialogState();
}

class _WishDialogState extends State<WishDialog> {
  final List<String> _wishTemplates = [
    'Happy Birthday! 🎉 Hope your special day brings you lots of happiness, love, and fun!',
    'Wishing you a wonderful birthday and a year ahead that\'s full of joy and success! 🎂',
    'Happy Birthday! May all your dreams and wishes come true! 🌟',
    'Another year older, another year wiser! Happy Birthday! 🎈',
    'Hope your special day is filled with lots of love, laughter, and happiness! 🎁',
    'Sending you warm wishes on your birthday! Have a fantastic day! 🎊',
    'Happy Birthday! May this new year of your life be the best one yet! 🎉',
    'Wishing you a day that\'s as special as you are! Happy Birthday! 🎂',
  ];

  String _selectedMessage = '';
  final TextEditingController _customMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMessage = _wishTemplates[0];
    _customMessageController.text = _wishTemplates[0];
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  void _sendWish() {
    final message = _customMessageController.text.trim();
    if (message.isNotEmpty) {
      Share.share(
        '$message\n\n${widget.birthday.name}\'s Birthday - ${_formatDate(widget.birthday.birthdate)}',
        subject: 'Happy Birthday ${widget.birthday.name}!',
      );
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Send Birthday Wish',
                  style: AppTheme.heading3(isDark),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.onSurface(isDark),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              'To: ${widget.birthday.name}',
              style: AppTheme.labelLarge(isDark).copyWith(
                color: AppTheme.onSurfaceVariant(isDark),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Text(
              'Choose a template or write your own:',
              style: AppTheme.labelMedium(isDark),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _wishTemplates.length,
                itemBuilder: (context, index) {
                  final template = _wishTemplates[index];
                  final isSelected = _selectedMessage == template;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMessage = template;
                        _customMessageController.text = template;
                      });
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.surfaceContainer(isDark),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.outline(isDark),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        template,
                        style: AppTheme.bodySmall(isDark),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            TextField(
              controller: _customMessageController,
              maxLines: 3,
              style: AppTheme.bodyMedium(isDark),
              decoration: InputDecoration(
                labelText: 'Custom Message',
                hintText: 'Write your own message...',
                hintStyle: AppTheme.bodyMedium(isDark).copyWith(
                  color: AppTheme.onSurfaceDisabled(isDark),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedMessage = '';
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingLG),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.labelLarge(isDark),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendWish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMD),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send, size: 18),
                        const SizedBox(width: AppTheme.spacingSM),
                        Text(
                          'Send',
                          style: AppTheme.labelLarge(isDark)
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
