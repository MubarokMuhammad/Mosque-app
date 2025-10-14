import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../config/app_config.dart';

class NotificationService {
  static late TwilioFlutter _twilioFlutter;
  static late SmtpServer _smtpServer;

  static void initialize() {
    // Initialize Twilio
    _twilioFlutter = TwilioFlutter(
      accountSid: AppConfig.twilioAccountSid,
      authToken: AppConfig.twilioAuthToken,
      twilioNumber: '+1234567890', // You'll need to get this from Twilio
    );

    // Initialize SMTP
    _smtpServer = SmtpServer(
      AppConfig.smtpHost,
      port: AppConfig.smtpPort,
      username: AppConfig.smtpUsername,
      password: AppConfig.smtpPassword,
      ssl: false,
      allowInsecure: true,
    );
  }

  // Send email notification
  static Future<bool> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    try {
      final message = Message()
        ..from = Address(AppConfig.smtpUsername, 'Service Hub App')
        ..recipients.add(to)
        ..subject = subject;

      if (isHtml) {
        message.html = body;
      } else {
        message.text = body;
      }

      final sendReport = await send(message, _smtpServer);
      print('Email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  // Send SMS notification
  static Future<bool> sendSMSNotification({
    required String to,
    required String message,
  }) async {
    try {
      await _twilioFlutter.sendSMS(
        toNumber: to,
        messageBody: message,
      );
      print('SMS sent to $to');
      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // Send event reminder
  static Future<void> sendEventReminder({
    required String userEmail,
    required String userPhone,
    required String eventTitle,
    required DateTime eventDateTime,
    required String organizationName,
    bool sendEmail = false,
    bool sendSMS = false,
  }) async {
    final eventDateStr = '${eventDateTime.day}/${eventDateTime.month}/${eventDateTime.year}';
    final eventTimeStr = '${eventDateTime.hour}:${eventDateTime.minute.toString().padLeft(2, '0')}';

    if (sendEmail) {
      final emailSubject = 'Event Reminder: $eventTitle';
      final emailBody = '''
Dear User,

This is a reminder for the upcoming event:

Event: $eventTitle
Organization: $organizationName
Date: $eventDateStr
Time: $eventTimeStr

Don't forget to attend!

Best regards,
Service Hub Team
      ''';

      await sendEmailNotification(
        to: userEmail,
        subject: emailSubject,
        body: emailBody,
      );
    }

    if (sendSMS) {
      final smsMessage = 'Reminder: $eventTitle by $organizationName on $eventDateStr at $eventTimeStr. Don\'t miss it!';
      
      await sendSMSNotification(
        to: userPhone,
        message: smsMessage,
      );
    }
  }

  // Send announcement notification
  static Future<void> sendAnnouncementNotification({
    required String userEmail,
    required String userPhone,
    required String announcementTitle,
    required String organizationName,
    bool sendEmail = false,
    bool sendSMS = false,
  }) async {
    if (sendEmail) {
      final emailSubject = 'New Announcement: $announcementTitle';
      final emailBody = '''
Dear User,

A new announcement has been posted:

Title: $announcementTitle
Organization: $organizationName

Check the app for more details.

Best regards,
Service Hub Team
      ''';

      await sendEmailNotification(
        to: userEmail,
        subject: emailSubject,
        body: emailBody,
      );
    }

    if (sendSMS) {
      final smsMessage = 'New announcement: $announcementTitle by $organizationName. Check the app for details.';
      
      await sendSMSNotification(
        to: userPhone,
        message: smsMessage,
      );
    }
  }

  // Send event cancellation notification
  static Future<void> sendEventCancellationNotification({
    required String userEmail,
    required String userPhone,
    required String eventTitle,
    required String organizationName,
    bool sendEmail = false,
    bool sendSMS = false,
  }) async {
    if (sendEmail) {
      final emailSubject = 'Event Cancelled: $eventTitle';
      final emailBody = '''
Dear User,

We regret to inform you that the following event has been cancelled:

Event: $eventTitle
Organization: $organizationName

We apologize for any inconvenience caused.

Best regards,
Service Hub Team
      ''';

      await sendEmailNotification(
        to: userEmail,
        subject: emailSubject,
        body: emailBody,
      );
    }

    if (sendSMS) {
      final smsMessage = 'Event Cancelled: $eventTitle by $organizationName. Sorry for the inconvenience.';
      
      await sendSMSNotification(
        to: userPhone,
        message: smsMessage,
      );
    }
  }

  // Send organization invitation
  static Future<void> sendOrganizationInvitation({
    required String userEmail,
    required String userPhone,
    required String organizationName,
    required String role, // 'admin' or 'member'
    bool sendEmail = false,
    bool sendSMS = false,
  }) async {
    if (sendEmail) {
      final emailSubject = 'Organization Invitation: $organizationName';
      final emailBody = '''
Dear User,

You have been invited to join $organizationName as a $role.

Please check the app to accept or decline this invitation.

Best regards,
Service Hub Team
      ''';

      await sendEmailNotification(
        to: userEmail,
        subject: emailSubject,
        body: emailBody,
      );
    }

    if (sendSMS) {
      final smsMessage = 'You\'ve been invited to join $organizationName as a $role. Check the app to respond.';
      
      await sendSMSNotification(
        to: userPhone,
        message: smsMessage,
      );
    }
  }
}