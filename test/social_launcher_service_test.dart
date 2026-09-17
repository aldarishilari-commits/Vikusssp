import 'package:flutter_test/flutter_test.dart';
import 'package:aeronpulse/core/services/social_launcher_service.dart';

void main() {
  group('SocialLauncherService URL formatting tests', () {
    test('Facebook formatting handles full URLs, domains, @handles, and usernames', () {
      // 1. Full HTTPS URL
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: 'https://facebook.com/bodyxtremelapaz',
        ),
        'https://facebook.com/bodyxtremelapaz',
      );

      // 2. Domain without https://
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: 'facebook.com/bodyxtremelapaz',
        ),
        'https://facebook.com/bodyxtremelapaz',
      );

      // 3. WWW domain
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: 'www.facebook.com/bodyxtremelapaz',
        ),
        'https://www.facebook.com/bodyxtremelapaz',
      );

      // 4. Handle with @
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: '@bodyxtremelapaz',
        ),
        'https://www.facebook.com/bodyxtremelapaz',
      );

      // 5. Raw username
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: 'bodyxtremelapaz',
        ),
        'https://www.facebook.com/bodyxtremelapaz',
      );

      // 6. Blank / empty
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.facebook,
          rawValue: '   ',
        ),
        '',
      );
    });

    test('TikTok formatting handles handles, domains, full URLs, and raw usernames', () {
      // 1. Full HTTPS URL
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.tiktok,
          rawValue: 'https://www.tiktok.com/@bodyxtreme',
        ),
        'https://www.tiktok.com/@bodyxtreme',
      );

      // 2. Domain without https://
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.tiktok,
          rawValue: 'tiktok.com/@bodyxtreme',
        ),
        'https://tiktok.com/@bodyxtreme',
      );

      // 3. Handle with @
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.tiktok,
          rawValue: '@bodyxtreme',
        ),
        'https://www.tiktok.com/@bodyxtreme',
      );

      // 4. Plain handle without @
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.tiktok,
          rawValue: 'bodyxtreme',
        ),
        'https://www.tiktok.com/@bodyxtreme',
      );

      // 5. Blank
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.tiktok,
          rawValue: '',
        ),
        '',
      );
    });

    test('Instagram formatting handles handles, domains, full URLs, and raw usernames', () {
      // 1. Full HTTPS URL
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.instagram,
          rawValue: 'https://instagram.com/bodyxtreme.bo',
        ),
        'https://instagram.com/bodyxtreme.bo',
      );

      // 2. Domain without https://
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.instagram,
          rawValue: 'instagram.com/bodyxtreme.bo',
        ),
        'https://instagram.com/bodyxtreme.bo',
      );

      // 3. Handle with @
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.instagram,
          rawValue: '@bodyxtreme.bo',
        ),
        'https://www.instagram.com/bodyxtreme.bo',
      );

      // 4. Plain username
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.instagram,
          rawValue: 'bodyxtreme.bo',
        ),
        'https://www.instagram.com/bodyxtreme.bo',
      );

      // 5. Blank
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.instagram,
          rawValue: '   ',
        ),
        '',
      );
    });

    test('Website formatting handles full URLs, subdomains, and plain domains', () {
      // 1. Full HTTPS URL
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.website,
          rawValue: 'https://bodyxtreme.com',
        ),
        'https://bodyxtreme.com',
      );

      // 2. Full HTTP URL
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.website,
          rawValue: 'http://bodyxtreme.com',
        ),
        'http://bodyxtreme.com',
      );

      // 3. Plain domain
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.website,
          rawValue: 'bodyxtreme.com',
        ),
        'https://bodyxtreme.com',
      );

      // 4. WWW domain
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.website,
          rawValue: 'www.bodyxtreme.com',
        ),
        'https://www.bodyxtreme.com',
      );

      // 5. Blank
      expect(
        SocialLauncherService.formatSocialUrl(
          platform: SocialPlatform.website,
          rawValue: '',
        ),
        '',
      );
    });

    test('Platform label returns correct human-readable names', () {
      expect(SocialLauncherService.getPlatformLabel(SocialPlatform.facebook), 'Facebook');
      expect(SocialLauncherService.getPlatformLabel(SocialPlatform.tiktok), 'TikTok');
      expect(SocialLauncherService.getPlatformLabel(SocialPlatform.instagram), 'Instagram');
      expect(SocialLauncherService.getPlatformLabel(SocialPlatform.website), 'Página Web');
    });
  });
}
