import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  static Future<void> openGoogleMaps(double lat, double lng) async {
    if (Platform.isAndroid) {
      // Android: Google Maps navigation deep link (real lat=lng, real lng=lat)
      final appUri = Uri.parse('google.navigation:q=$lng,$lat&mode=d');
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
        return;
      }
    } else if (Platform.isIOS) {
      // iOS: Google Maps native scheme
      final appUri = Uri.parse(
        'comgooglemaps://?daddr=$lng,$lat&directionsmode=driving',
      );
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
        return;
      }
    }

    // Fallback: browser
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lng,$lat&travelmode=driving',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openYandexMaps(double lat, double lng) async {
    // Yandex Maps deep link (Android & iOS)
    final appUri = Uri.parse(
      'yandexmaps://maps.yandex.ru/?rtext=~$lng,$lat&rtt=auto',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }

    // Fallback: browser
    final webUri = Uri.parse(
      'https://yandex.com/maps/?rtext=~$lng,$lat&rtt=auto',
    );
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}