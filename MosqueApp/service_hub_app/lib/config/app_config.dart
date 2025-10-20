class AppConfig {
  // SMTP Configuration
  static const String smtpUsername = 'REMOVED_SECRET';
  static const String smtpPassword = 'REMOVED_SECRET';
  static const String smtpHost = 'REMOVED_SECRET';
  static const int smtpPort = 587;

  // Twilio Configuration
  static const String twilioAccountSid = 'REMOVED_SECRET';
  static const String twilioAuthToken = 'REMOVED_SECRET';
  static const String twilioServiceSid = 'REMOVED_SECRET';

  // App Theme Colors
  static const int primaryTealColor = 0xFF20B2AA; // Light Sea Green
  static const int secondaryTealColor = 0xFF008B8B; // Dark Cyan
  static const int whiteColor = 0xFFFFFFFF;
  static const int lightGreyColor = 0xFFF5F5F5;
  static const int darkGreyColor = 0xFF757575;

  // App Constants
  static const String appName = 'UmmaHub';
  static const String appVersion = '1.0.0';
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
}
