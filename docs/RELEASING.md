# Testing gates and releases

Every change goes through three gates. The fast, deterministic ones run on
every pull request. The end-to-end flows run on this Mac before merging and on
GitHub after merging, every night and for every release.

| When | What runs | Where | Blocks |
|---|---|---|---|
| Every push (pre-push hook) | format, analyze, unit/widget/layout-matrix tests, goldens | this Mac, `tool/ci.sh` | the push |
| Every pull request | `analyze`, `test` (with coverage, uploaded as an artifact), `goldens` | GitHub | the merge (required checks) |
| Before merging | all of the above + release builds (Android app bundle with R8, iOS without signing) + e2e on the small (Spanish) and large (English) iPhone simulators and an Android emulator | this Mac, `tool/ci.sh all` | the merge (`local-e2e` required check) |
| After every merge, nightly, on demand | release builds, e2e on iPhone small (Spanish) / large (English), Android API 24 (small) and 35 (large), and a smoke test of the Android release build on API 35 | GitHub, workflow **E2E** | nothing: a red run is fixed in the next PR |
| Every `v*` tag | tag = pubspec version, all checks, goldens, e2e on the 4 CI devices | GitHub, workflow **Release** | the release |

## Why the e2e flows don't run on pull requests

Unit, widget, matrix and golden tests don't use devices, so they give the
same result every time. The e2e flows do use devices, and on GitHub's shared
machines the simulator or emulator sometimes fails to attach to the app before
the first test runs ("The log reader failed unexpectedly", "Failed to start
Dart Development Service"). That happens to about half the iOS jobs and says
nothing about the code; locally it hasn't happened once. `tool/ci.sh` retries
such a run once (a failure after a test has run is never retried). Keeping the
e2e flows off pull requests takes that noise, and ~12 minutes, off every
merge, while the local gate still guarantees they passed.

## The `local-e2e` gate

`main` only accepts a pull request whose head commit carries the commit status
`local-e2e`, and only `tool/ci.sh all` reports it:

1. Commit and push the branch.
2. Run `tool/ci.sh all`. It runs every check and the e2e flows on the small
   and large iPhone simulators and on an Android emulator (it starts the first
   AVD whose name contains `1rm` if none is running, and shuts down whatever it
   started). Setup of the Android side: README → Testing.
3. If everything passes **and** there are no uncommitted changes, it records
   the pass for that commit and reports `local-e2e ✓` on GitHub with a summary
   of the devices it ran on. If the commit wasn't pushed yet, push it and run
   `tool/ci.sh report`.

The status is tied to the exact commit. Any new commit, including updating the
branch with `main` (required before merging), needs a new `tool/ci.sh all`.

## Releasing a version

1. Bump `version:` in `pubspec.yaml` (`1.2.3+45`: name + build number, which
   must always grow) and the same values in `lib/data/app_info.dart` (shown
   in About; a test fails if they differ) in a pull request, and merge it
   through the gates above.
2. Check the latest **E2E** run on `main` is green.
3. Tag the merge commit and push the tag:
   ```bash
   git tag v1.2.3 && git push origin v1.2.3
   ```
4. The **Release** workflow must go green. Its last job uploads the signed
   bundle and the store listing to Google Play's **internal testing** track
   (workflow **Google Play**). If it doesn't go green, fix it in a pull
   request and release the next patch version; never move a published tag.
5. Promote the version in Play Console (closed testing, then production)
   once it has been tried on the internal track.
6. Upload the same version to TestFlight: Actions → **TestFlight** → Run
   workflow, on the tag (see TestFlight below; not part of the Release
   workflow yet).
7. Manual smoke test of the release build on a real iPhone (and Android when
   available): fresh install, update over the previous version with data,
   Spanish and English, 200 % text size and bold text, and one pass over
   every screen with VoiceOver (and TalkBack): each card, number, chart and
   icon button is announced with a name that makes sense. Phase 2 (#45) adds
   real devices on Firebase Test Lab.

## Debug symbols

Release builds are obfuscated and leave their debug symbols out of the app
(`--obfuscate --split-debug-info`, in `tool/ci.sh`): the code shipped is
smaller, and a stack trace from it reads as `#00 abs 0000… virt 0000…` with
made-up names instead of files and lines. The symbols are written to
`build/debug-info/android` and `build/debug-info/ios` (git-ignored), one
`app.<arch>.symbols` file per architecture, and only match the exact build
that wrote them. **Keep the symbols of every release** next to its tag: the
**Google Play** and **TestFlight** workflows keep those of the binary they
upload as an artifact for 90 days (`debug-symbols-<platform>-<commit>`);
download them before they expire.

To read a stack trace from a release build (from Play Console, Crashlytics,
`adb logcat` or an iPhone crash log), save it to a file and symbolize it
with the file of the device's architecture:

```bash
flutter symbolize -i trace.txt -d build/debug-info/android/app.android-arm64.symbols
flutter symbolize -i trace.txt -d build/debug-info/ios/app.ios-arm64.symbols
```

Obfuscation renames classes and functions, so code must never depend on a
type's name at run time (`runtimeType.toString()`, `Type.toString()`), for
example in saved JSON or logs. Enum `.name` and string literals are safe.

## Android release signing and the Play upload

Release bundles are signed with the upload key; Google Play re-signs them
with the app signing key it keeps (Play App Signing), so a lost upload key
can be replaced by asking Play for a new one.

- **Locally**: `android/key.properties` (git-ignored) points at
  `~/keys/1rm-upload-keystore.jks` (PKCS12, alias `upload`, one password for
  the store and the key). Without that file release builds fall back to the
  debug key, fine for local and CI builds but refused by Google Play. The
  keystore and its `key.properties` are backed up by the owner.
- **In CI**: the **Google Play** workflow (`play.yml`) rebuilds the keystore
  and `key.properties` from the secrets `ANDROID_UPLOAD_KEYSTORE_BASE64` and
  `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, builds with `tool/ci.sh build-android`,
  keeps the debug symbols as an artifact for 90 days and uploads the bundle
  and the store listing in `fastlane/` with fastlane's
  `upload_to_play_store`, authenticated by the service account
  `play-publisher@larridev-play.iam.gserviceaccount.com` (secret
  `PLAY_SERVICE_ACCOUNT_JSON`; Google Cloud project `larridev-play`). It can
  also be run by hand from the Actions tab, choosing the track and whether
  the release is a draft (required while the app has never been published).
- Each upload needs a build number (`+N` in `pubspec.yaml`) higher than any
  uploaded before.

## iOS signing and the TestFlight upload

The App Store `.ipa` is built by `tool/ci.sh build-ipa`: Flutter writes the
release configuration (obfuscated, debug symbols split, version and build
number from `pubspec.yaml`), Xcode archives without signing, and the export
(`ios/ExportOptions.plist`: App Store Connect, automatic signing, team
`RQ236KP76M`) signs it with **cloud-managed signing**: Apple keeps the
distribution certificate, so no certificate or provisioning profile lives on
the machine or in the repository.

- **Locally**: `tool/ci.sh build-ipa` signs as the Apple account signed in to
  Xcode (Settings → Accounts) and writes `build/ios/ipa/one_rm_mobile.ipa`.
  To upload it, put the API key's `.p8` outside the repository (e.g.
  `~/keys/AuthKey_<KEY_ID>.p8`; `*.p8` is git-ignored anyway), install
  fastlane (`brew install fastlane`) and run:
  ```bash
  export ASC_KEY_ID=<key id> ASC_ISSUER_ID=<issuer id> ASC_KEY_PATH=~/keys/AuthKey_<key id>.p8
  tool/ci.sh build-ipa && tool/ci.sh upload-testflight
  ```
  With the three variables set, `build-ipa` also signs as the key instead of
  the Xcode account, exactly as CI does. Missing variables or a missing
  `.ipa` fail with a message saying what is missing.
- **In CI**: the **TestFlight** workflow (`testflight.yml`, macOS runner)
  writes the key from the secrets to the runner's temp folder, runs the same
  two commands, and keeps the debug symbols as an artifact for 90 days. Run
  it by hand from the Actions tab on `main` or on a tag.
- **The upload** is fastlane's `upload_to_testflight` (the same tool as the
  Play upload), with `skip_waiting_for_build_processing`: it uploads and
  returns; App Store Connect processes the build in ~10–30 min and then
  internal testers get it. Nothing is submitted to Beta App Review or App
  Review and the store listing in `fastlane/` is not sent.
- **Build number**: the same `+N` of `pubspec.yaml` as Android's versionCode.
  App Store Connect refuses a build number already uploaded for that
  version, so every upload needs a bump through a pull request, as for Play.
  Re-running the workflow on the same commit fails at the upload with that
  error, after building.

### The App Store Connect API key

Done once by the Account Holder in App Store Connect:

1. Users and Access → Integrations → App Store Connect API → **Team Keys**
   (request access the first time). Generate a key named e.g. `CI upload`
   with access **App Manager**. A key's role cannot be changed later.
2. Note the **Issuer ID** (above the list) and the **Key ID**, and download
   the `.p8` (only possible once). Keep it outside the repository, backed up
   like the Android upload key.
3. Add three repository secrets (Settings → Secrets and variables →
   Actions), never committed or printed:
   - `ASC_KEY_ID`: the Key ID.
   - `ASC_ISSUER_ID`: the Issuer ID.
   - `ASC_KEY_P8`: the `.p8` in base64, from
     `base64 -i AuthKey_<KEY_ID>.p8 | pbcopy`.

**App Manager or Admin.** App Manager is the least privilege that can upload
to TestFlight. Cloud-managed signing from CI also has to use the team's
distribution certificate, and Apple documents creating and managing those
for Account Holders and Admins; whether an App Manager key is enough is
unverified until the first run. If that run fails in `build-ipa` at the
export step with a signing or certificate error (for example "Cloud signing
permission error" or "No signing certificate"), create a new team key with
access **Admin** and replace the three secrets: nothing else changes.

### Running it on every release

Once a manual run has uploaded a build, the Release workflow can call it for
every tag, next to the Play job:

```yaml
  testflight:
    needs: [version, checks, e2e]
    uses: ./.github/workflows/testflight.yml
    secrets: inherit
```

It isn't wired yet because before the secrets exist that job would fail and
turn every release red.

## When the E2E run on main fails

Open the run, look at which device and which step failed:

- **"e2e infrastructure failure … on attempt 2"**: the device failed to attach
  twice in a row. Re-run the job; if it keeps happening, look at the runner
  image or the Flutter version.
- **A failing test** (❌ with a test name): a real regression that slipped past
  the local gate, most likely Android-only if the Mac has no emulator. Fix it
  in the next pull request with a test that reproduces it.
