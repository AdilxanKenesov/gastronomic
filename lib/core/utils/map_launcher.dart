import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openGoogleMaps(double lat, double lng) async {
    // Native app deep link
    final appUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    // Browser fallback
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openYandexMaps(double lat, double lng) async {
    // Native app deep link
    final appUrl = Uri.parse(
      'yandexmaps://maps.yandex.com/?rtext=~$lat,$lng&rtt=auto',
    );
    // Browser fallback
    final webUrl = Uri.parse(
      'https://yandex.com/maps/?rtext=~$lat,$lng&rtt=auto',
    );

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}