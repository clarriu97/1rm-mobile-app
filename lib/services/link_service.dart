import 'package:url_launcher/url_launcher.dart';

/// Opens web pages in the browser and mail links in the mail app.
abstract class LinkService {
  /// False when nothing on the device could open [url].
  Future<bool> open(Uri url);

  static LinkService getInstance() => _UrlLauncherLinkService();

  static FakeLinkService forTesting({bool succeeds = true}) =>
      FakeLinkService(succeeds: succeeds);
}

class _UrlLauncherLinkService implements LinkService {
  @override
  Future<bool> open(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}

/// Records the links it was asked to open.
class FakeLinkService implements LinkService {
  FakeLinkService({this.succeeds = true});

  final bool succeeds;
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return succeeds;
  }
}
