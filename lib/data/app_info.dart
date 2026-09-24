/// Version shown in the app. Must match `version:` in pubspec.yaml (a test
/// checks it); bump both in the release PR.
const String appVersion = '0.1.0';
const int appBuildNumber = 1;

final Uri websiteUrl = Uri.https('1rm.larri.dev', '/');
final Uri privacyUrl = Uri.https('1rm.larri.dev', '/privacy/');
final Uri termsUrl = Uri.https('1rm.larri.dev', '/terms/');
const String supportEmail = 'info.1rm@larri.dev';
final Uri supportEmailUrl = Uri(scheme: 'mailto', path: supportEmail);
