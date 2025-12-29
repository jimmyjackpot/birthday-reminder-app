import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../theme/app_theme.dart';
import '../services/permission_service.dart';

class ContactPicker extends StatefulWidget {
  final String? selectedContactId;
  final Function(Contact?) onContactSelected;

  const ContactPicker({
    super.key,
    this.selectedContactId,
    required this.onContactSelected,
  });

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _selectedContactId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedContactId = widget.selectedContactId;
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    try {
      final hasPermission =
          await PermissionService.requestContactsPermission(context);
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Contacts permission is required to select a contact'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final granted = await FlutterContacts.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contacts permission denied'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
        withAccounts: false,
      );

      // Sort contacts by name
      contacts.sort((a, b) => a.displayName.compareTo(b.displayName));

      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.getSurfaceColor(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Select Contact',
                  style: AppTheme.heading3(isDark),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.getTextPrimaryColor(isDark),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: AppTheme.bodyMedium(isDark).copyWith(
                  color: AppTheme.getTextTertiaryColor(isDark),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.getTextSecondaryColor(isDark),
                ),
                filled: true,
                fillColor: AppTheme.getBackgroundColor(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTheme.bodyMedium(isDark),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingMD),
            // Contact list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.contacts_outlined,
                                size: 64,
                                color: AppTheme.getTextTertiaryColor(isDark),
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              Text(
                                'No contacts found',
                                style: AppTheme.bodyMedium(isDark).copyWith(
                                  color: AppTheme.getTextSecondaryColor(isDark),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            final filteredContacts = _searchQuery.isEmpty
                                ? _contacts
                                : _contacts.where((contact) {
                                    final query = _searchQuery.toLowerCase();
                                    return contact.displayName
                                            .toLowerCase()
                                            .contains(query) ||
                                        (contact.phones.isNotEmpty &&
                                            contact.phones.first.number
                                                .contains(query));
                                  }).toList();

                            if (filteredContacts.isEmpty &&
                                _searchQuery.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color:
                                          AppTheme.getTextTertiaryColor(isDark),
                                    ),
                                    const SizedBox(height: AppTheme.spacingMD),
                                    Text(
                                      'No contacts match your search',
                                      style:
                                          AppTheme.bodyMedium(isDark).copyWith(
                                        color: AppTheme.getTextSecondaryColor(
                                            isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: filteredContacts.length +
                                  1, // +1 for "None" option
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // "None" option
                                  return ListTile(
                                    leading: Icon(
                                      Icons.person_off,
                                      color: AppTheme.getTextSecondaryColor(
                                          isDark),
                                    ),
                                    title: Text(
                                      'No Contact',
                                      style: AppTheme.bodyMedium(isDark),
                                    ),
                                    selected: _selectedContactId == null,
                                    selectedTileColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    onTap: () {
                                      setState(() {
                                        _selectedContactId = null;
                                      });
                                      widget.onContactSelected(null);
                                      Navigator.pop(context);
                                    },
                                  );
                                }

                                final contact = filteredContacts[index - 1];
                                final isSelected =
                                    _selectedContactId == contact.id;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    backgroundImage: contact.photo != null
                                        ? MemoryImage(contact.photo!)
                                        : null,
                                    child: contact.photo == null
                                        ? Text(
                                            contact.displayName.isNotEmpty
                                                ? contact.displayName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: AppTheme.labelLarge(isDark)
                                                .copyWith(
                                              color: AppTheme.primaryColor,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    style: AppTheme.bodyMedium(isDark),
                                  ),
                                  subtitle: contact.phones.isNotEmpty
                                      ? Text(
                                          contact.phones.first.number,
                                          style: AppTheme.bodySmall(isDark),
                                        )
                                      : null,
                                  selected: isSelected,
                                  selectedTileColor: AppTheme.primaryColor
                                      .withValues(alpha: 0.1),
                                  onTap: () {
                                    setState(() {
                                      _selectedContactId = contact.id;
                                    });
                                    widget.onContactSelected(contact);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
