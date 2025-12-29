# Geist Font Setup Instructions

The app is configured to use **Geist** font, a modern sans-serif typeface by Vercel.

## Download Geist Font

1. Visit [Vercel's Geist Font page](https://vercel.com/font) or [GitHub repository](https://github.com/vercel/geist-font)
2. Download the font files (TTF format)
3. You'll need these weights:
   - Geist-Regular.ttf (weight: 400)
   - Geist-Medium.ttf (weight: 500)
   - Geist-SemiBold.ttf (weight: 600)
   - Geist-Bold.ttf (weight: 700)

## Installation Steps

1. Place the downloaded font files in the `fonts/` directory at the root of the project:
   ```
   fonts/
   ├── Geist-Regular.ttf
   ├── Geist-Medium.ttf
   ├── Geist-SemiBold.ttf
   └── Geist-Bold.ttf
   ```

2. The `pubspec.yaml` file is already configured with the font references.

3. Run `flutter pub get` to ensure the fonts are registered.

4. Restart your app to see the Geist font applied.

## Alternative: Using Google Fonts (Temporary)

If you want to use a similar font temporarily while setting up Geist, you can modify `lib/theme/app_theme.dart` to use Inter or another similar font from Google Fonts.

## Notes

- The app will fall back to system fonts (SF Pro Display on iOS, Roboto on Android) if Geist font files are not found.
- Make sure the font file names match exactly as specified in `pubspec.yaml`.
- After adding the fonts, run `flutter clean` and rebuild the app.

