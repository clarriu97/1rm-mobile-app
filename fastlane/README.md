# Store listings

What App Store Connect and Google Play show, in the folder layout of
fastlane's `deliver` (App Store) and `supply` (Google Play), so a release job
can upload it. English (`en-US`) is the default language; Spanish (`es-ES`) is
a translation. Texts have no trailing newline: what is in the file is what
the store gets.

| Folder | What |
|---|---|
| `metadata/<locale>/` | App Store texts: `name`, `subtitle`, `promotional_text`, `description`, `keywords`, `release_notes`, and the support, marketing and privacy URLs |
| `screenshots/<locale>/` | App Store screenshots, iPhone 6.9" (1320 × 2868), JPEG |
| `metadata/android/<locale>/` | Google Play texts: `title`, `short_description`, `full_description` |
| `metadata/android/<locale>/images/phoneScreenshots/` | Google Play phone screenshots (1080 × 1920), JPEG |
| `metadata/android/<locale>/images/featureGraphic.jpg` | Google Play feature graphic (1024 × 500), JPEG |
| `metadata/android/<locale>/images/icon.png` | Google Play icon (512 × 512), the launcher icon `assets/branding/app_icon.png` resized with `sips` |

## Store limits

`test/platform/store_listing_test.dart` checks them, so an edit that would
break an upload fails the tests.

| Store | Field | Limit |
|---|---|---|
| App Store | name, subtitle | 30 characters |
| App Store | promotional text | 170 |
| App Store | description, release notes | 4000 |
| App Store | keywords | 100, comma-separated with no spaces after commas, no words already in the name |
| Google Play | title | 30 |
| Google Play | short description | 80 |
| Google Play | full description | 4000, plain text |

Google Play also refuses "free", prices, rankings ("best", "#1") and other
apps' names in the title and short description. Screenshots and the feature
graphic must have no alpha channel, which is why they are JPEG.

## Regenerating the images

The images are never edited by hand. `test/goldens/store_test.dart` lays
out the app's real screens with sample data and writes them as goldens to
`test/goldens/goldens/store/`; `tool/store_images.sh` converts them to JPEG
into these folders and resizes the icon. On macOS:

```bash
flutter test --update-goldens --tags golden test/goldens/store_test.dart
tool/store_images.sh
```
