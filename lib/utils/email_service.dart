import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';

class EmailService {
  // ⚠️ MUHIMU: Hii ni Gmail App Password, SIO nywila yako ya kawaida ya Gmail.
  static const String _senderEmail = 'paulomkenya0@gmail.com';
  static const String _appPassword = 'tocb yxrc ovdv cfra';
  static const String _recipientEmail = 'paulomkenya0@gmail.com';

  static Future<bool> sendOtpEmail(String otp, String forUsername) async {
    final smtpServer = gmail(_senderEmail, _appPassword);

    final message = Message()
      ..from = Address(_senderEmail, 'Mfumo wa Viongozi - Muleba')
      ..recipients.add(_recipientEmail)
      ..subject = 'Nambari ya Kurejesha Nywila - $forUsername'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
          <div style="background: #1B5E20; padding: 20px; border-radius: 8px 8px 0 0;">
            <h2 style="color: white; margin: 0;">Wilaya ya Muleba</h2>
            <p style="color: #F9A825; margin: 4px 0 0;">Mfumo wa Usimamizi wa Viongozi</p>
          </div>
          <div style="padding: 24px; background: #f5f7f2; border-radius: 0 0 8px 8px;">
            <p>Ombi la kurejesha nywila limepokelewa kwa mtumiaji: <b>$forUsername</b></p>
            <div style="background: white; padding: 20px; text-align: center; border-radius: 8px; margin: 16px 0;">
              <p style="color: #6B7280; font-size: 13px; margin: 0 0 8px;">NAMBARI YA UTHIBITISHO</p>
              <p style="font-size: 32px; font-weight: 800; color: #1B5E20; letter-spacing: 4px; margin: 0;">$otp</p>
            </div>
            <p style="color: #6B7280; font-size: 13px;">Nambari hii itaisha muda baada ya dakika 10. Kama hukufanya ombi hili, puuza ujumbe huu.</p>
          </div>
        </div>
      ''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Inatuma database kama attachment kwa email ya admin.
  /// Hii inafanya kazi "kimya" bila kuonyesha chochote kwa mtumiaji.
  static Future<bool> sendBackupEmail({
    required String dbFilePath,
    required String username,
  }) async {
    try {
      final smtpServer = gmail(_senderEmail, _appPassword);
      final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final fileName = 'muleba_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db';

      final message = Message()
        ..from = Address(_senderEmail, 'Mfumo wa Viongozi - Muleba (Auto-Backup)')
        ..recipients.add(_recipientEmail)
        ..subject = 'Auto-Backup: Login ya $username — $now'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
            <div style="background: #1B5E20; padding: 16px; border-radius: 8px 8px 0 0;">
              <h3 style="color: white; margin: 0;">Auto-Backup ya Mfumo</h3>
            </div>
            <div style="padding: 20px; background: #f5f7f2; border-radius: 0 0 8px 8px;">
              <p>Mtumiaji <b>$username</b> ameingia mfumoni saa: <b>$now</b></p>
              <p style="color: #6B7280; font-size: 13px;">Nakala ya database imeshikamanishwa (attached) kwenye ujumbe huu.</p>
            </div>
          </div>
        '''
        ..attachments = [FileAttachment(File(dbFilePath))];

      await send(message, smtpServer);
      return true;
    } catch (e) {
      // Backup ikishindwa, hatutaki kuvuruga uzoefu wa mtumiaji - return false kimya
      return false;
    }
  }
}
