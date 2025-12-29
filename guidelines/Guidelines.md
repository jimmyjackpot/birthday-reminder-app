1. General Principles

These rules govern overall file structure, layout quality, and design consistency.
	•	Component-First Design: All reusable UI elements must be created as components with clear naming and variants (e.g., PrimaryButton/Default, PrimaryButton/Hover, PrimaryButton/Disabled).
	•	Semantic Naming: Frame and component names must match Flutter class/route naming conventions (PascalCase). Example: BirthdayListScreen, AddBirthdayForm.
	•	Auto Layout & Constraints: Use auto layout on all parent containers and lists. Apply proper constraints for responsiveness on various screen sizes.
	•	Modularity: Split large screens into logical UI components. Do not merge unrelated elements in the same frame.
	•	File Organization: Use pages per major domain (e.g., “Authentication”, “Main UI”, “Settings”), and clearly mark deprecated drafts.

⸻

2. Layout & Interaction Rules

Rules ensuring designs export into structured, scalable code.
	•	Use Auto Layout Hierarchies: Ensure vertical/horizontal layouts map cleanly to Flutter Column/Row widgets.
	•	Avoid Absolute Positioning: Only use absolute positioning for overlays/modals. Default to flex layouts for content.
	•	Responsive Scaling: Text sizes, spacing, grids must use Figma scale tokens to support multiple screen sizes.
	•	Interactive States: Define visual variants for states (hover, pressed, focus) for interactive components.
	•	Prototypes With Navigation: Annotate screen transitions using Figma prototype links matching expected navigation flows (e.g., Login → Home → Birthday Detail).

⸻

3. Design System Guidelines

Define consistent token usage and component behavior.

Color System
	•	Primary brand color should be applied consistently across key CTAs.
	•	Neutral palette must ensure contrast and accessibility compliance.
	•	Ad placement region backgrounds should not clash with app branding.

Typography
	•	Define text styles: Heading1, Heading2, Body, Caption.
	•	Maintain consistent scale — do not mix disparate sizes without purpose.

Iconography
	•	Use consistent icon style across UI (rounded/outlined/filled).
	•	Icons must be components with scalable vector formats.

⸻

4. UX Conventions for Birthday Reminder App

Tailored for the specific functionality of a birthday reminder app with AdMob integration.  ￼

Home & Dashboard
	•	Upcoming List: Users see next birthdays sorted by days left.
	•	Calendar View: Monthly overview with marked birthdays.
	•	Ads Integration: Include design placements for banner ads (fixed bottom) and interstitial ad placeholders between navigations.

Profile & Authentication
	•	Login/Registration: Ensure secure and clear login flow places for authentication.
	•	Profile Editing: Editable avatar, name, and contact details with inline validations.

Add/Edit Birthday
	•	Form UX: Clear inputs for name, date, photo, and reminder settings.
	•	Confirmation Feedback: Visual confirmation (toast/modal) after saving or deleting.

Wish UI
	•	Quick Actions: Buttons for sending predefined messages or custom messages.
	•	Social Sharing: Integrate sharing icons for WhatsApp, SMS, social media.

⸻

5. Flutter Export Conventions

Instructions to ensure Figma exports translate reliably into Flutter.
	•	Screen Frame Naming: Should map to Flutter route names (HomeScreen, BirthdayDetailScreen).
	•	Component to Widget Mapping: Every major component must export into a separate Dart file (BirthdayCard.dart, CalendarWidget.dart).
	•	Styles to Theme: All color/text styles should be exported as constants for use in ThemeData.
	•	Ad Slots Marked: Visually mark Ad placement components with notes (banner vs interstitial region) so tooling can generate Ad widget code.

⸻

6. Code Quality & Behavior Guidelines

Rules that govern how layouts become production-ready code.
	•	No Hard-Coded Sizes: Favor relative/flex layouts (percent, expanded) to match device variability.
	•	Accessibility: All interactive elements should have accessible labels and touch targets.
	•	AdMob Integration Constraints:
	•	Annotate areas for banner ad (mobile_ads/banner) and interstitial ad (mobile_ads/interstitial).
	•	Ensure ads do not overlap primary navigation or obstruct user flow.
	•	Navigation Patterns: Use named routes and consistent transitions (e.g., fade or slide) in prototypes.

⸻

7. Documentation & Tokens

Ensure the Figma file includes concise documentation for AI tooling.
	•	Design Tokens Page: With all color, spacing, and typography tokens.
	•	Component Library Page: With all components and variants showing state differences.
	•	Export Notes: Include direct notes for each screen/section indicating expected Flutter code structure and Ad placements.

⸻

8. Birthday Reminder App Specific

Use constraints that align with the application’s intent: simplicity, clarity, and nostalgia.
	•	Countdown Cards: Highlight days remaining with emphatic typography.
	•	Reminder UI: Easy toggles for notification time and frequency.
	•	Empty States: Provide clear guidance in calendar/list when no birthdays exist.