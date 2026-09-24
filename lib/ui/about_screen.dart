import 'package:flutter/material.dart';
import '../data/app_info.dart';
import '../l10n/app_localizations.dart';
import '../services/link_service.dart';
import 'theme/app_theme.dart';

/// Version, where the data lives, and the links a store listing requires.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.links});

  final LinkService links;

  Future<void> _open(BuildContext context, Uri url, String shown) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).couldNotOpen(shown);
    if (await links.open(url)) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final version = l10n.version(appVersion, appBuildNumber);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          KnurlPanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HazardStripe(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1RM',
                        style: text.displayLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        version,
                        key: const Key('about-version'),
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.aboutTagline, style: text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.dataStaysOnDevice, style: text.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _LinkGroup(
            children: [
              _LinkTile(
                key: const Key('about-website'),
                icon: Icons.public_rounded,
                title: l10n.website,
                subtitle: websiteUrl.host,
                external: true,
                onTap: () => _open(context, websiteUrl, websiteUrl.host),
              ),
              _LinkTile(
                key: const Key('about-privacy'),
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                external: true,
                onTap: () => _open(context, privacyUrl, l10n.privacyPolicy),
              ),
              _LinkTile(
                key: const Key('about-terms'),
                icon: Icons.description_outlined,
                title: l10n.termsOfUse,
                external: true,
                onTap: () => _open(context, termsUrl, l10n.termsOfUse),
              ),
              _LinkTile(
                key: const Key('about-contact'),
                icon: Icons.mail_outline_rounded,
                title: l10n.contact,
                subtitle: supportEmail,
                external: true,
                onTap: () => _open(context, supportEmailUrl, supportEmail),
              ),
              _LinkTile(
                key: const Key('about-licenses'),
                icon: Icons.article_outlined,
                title: l10n.licenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: '1RM',
                  applicationVersion: version,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkGroup extends StatelessWidget {
  const _LinkGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) Container(height: 0.5, color: AppColors.outline),
            child,
          ],
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Leaves the app (browser, mail): marked with an "open outside" icon.
  final bool external;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: external,
      child: ListTile(
        minTileHeight: kMinTapTarget + 8,
        leading: Icon(icon, color: AppColors.accent),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Icon(
          external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
          size: 20,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
