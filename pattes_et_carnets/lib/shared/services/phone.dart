import 'package:url_launcher/url_launcher.dart';

/// Opens the dialer with [phone] pre-filled.
Future<void> callPhone(String phone) async {
  final uri = Uri.parse('tel:$phone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
