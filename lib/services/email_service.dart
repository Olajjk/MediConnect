import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  Future<void> sendEmail(
    String emailRecepteur,
    String sujet,
    String contenu,
  ) async {
    final smtpServer = gmail(
      'awademeronaldoo@gmail.com',
      'pwdw skzp ykak vugz',
    );

    final message =
        Message()
          ..from = const Address('awademeronaldoo@gmail.com', 'HOUEFFA')
          ..recipients.add(emailRecepteur)
          ..subject = sujet
          ..text = contenu;

    try {
      await send(message, smtpServer);
      print('E-mail envoyé avec succès !');
    } on MailerException catch (e) {
      print('Erreur lors de l\'envoi : ${e.message}');
    }
  }
}
