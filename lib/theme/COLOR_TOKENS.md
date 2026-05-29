# Color Token System

This app uses a semantic color token system following Material Design 3 principles for consistent theming across light and dark modes.

## Core Color Tokens

### Surface Tokens
- `AppTheme.surface(isDark)` - Primary surface color (cards, containers)
- `AppTheme.surfaceContainer(isDark)` - Background/scaffold color
- `AppTheme.surfaceElevated(isDark)` - Elevated surfaces (modals, dialogs)

### On Surface Tokens (Text Colors)
- `AppTheme.onSurface(isDark)` - Primary text color
- `AppTheme.onSurfaceVariant(isDark)` - Secondary text color
- `AppTheme.onSurfaceDisabled(isDark)` - Disabled/tertiary text color

### Outline Tokens (Borders)
- `AppTheme.outline(isDark)` - Primary border color
- `AppTheme.outlineVariant(isDark)` - Divider/separator color

## Extended Color Tokens

### Container Colors
- `AppTheme.pinkContainer(isDark)` - Light pink container (dark mode: dark pink)
- `AppTheme.tealContainer(isDark)` - Light teal container (dark mode: dark teal)
- `AppTheme.beigeContainer(isDark)` - Light beige container (dark mode: dark surface)
- `AppTheme.blueContainer(isDark)` - Blue accent (dark mode: lighter blue)
- `AppTheme.orangeContainer(isDark)` - Orange accent (dark mode: lighter orange)

## Brand Colors

### Primary Colors
- `AppTheme.primaryColor` - Coral Pink (#FF6B9D)
- `AppTheme.secondaryColor` - Teal Green (#4ECDC4)
- `AppTheme.accentColor` - Yellow/Amber (#FFE66D)

### Status Colors
- `AppTheme.successColor` - Green (#10B981)
- `AppTheme.errorColor` - Red (#EF4444)
- `AppTheme.warningColor` - Orange (#F59E0B)
- `AppTheme.infoColor` - Blue (#4A90E2)

## Usage Examples

```dart
// Background
backgroundColor: AppTheme.surfaceContainer(isDark)

// Card/Container
color: AppTheme.surface(isDark)

// Primary Text
color: AppTheme.onSurface(isDark)

// Secondary Text
color: AppTheme.onSurfaceVariant(isDark)

// Borders
border: Border.all(color: AppTheme.outline(isDark))

// Dividers
color: AppTheme.outlineVariant(isDark)

// Special Containers
color: AppTheme.pinkContainer(isDark)
color: AppTheme.tealContainer(isDark)
```

## Migration from Legacy Methods

Old methods are deprecated but still work for backward compatibility:
- `getBackgroundColor()` → `surfaceContainer()`
- `getSurfaceColor()` → `surface()`
- `getTextPrimaryColor()` → `onSurface()`
- `getTextSecondaryColor()` → `onSurfaceVariant()`
- `getBorderColor()` → `outline()`
- `getLightPink()` → `pinkContainer()`
- `getLightTeal()` → `tealContainer()`
- `getLightBeige()` → `beigeContainer()`
- `getLightBlue()` → `blueContainer()`
- `getOrange()` → `orangeContainer()`

## Benefits

1. **Semantic Naming** - Colors are named by purpose, not appearance
2. **Theme Consistency** - Automatic adaptation to light/dark mode
3. **Maintainability** - Change colors in one place, affects entire app
4. **Accessibility** - Proper contrast ratios maintained
5. **Scalability** - Easy to add new themes or color schemes

