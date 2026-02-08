using Actime.Model.Entities;
using System.Net;
using System.Net.Mail;

namespace Actime.Subscriber.Services
{
    public class EmailServiceHandler
    {
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;
        private readonly bool _enableSsl;

        public EmailServiceHandler(
            string smtpHost,
            int smtpPort,
            string smtpUsername,
            string smtpPassword,
            string fromEmail,
            string fromName,
            bool enableSsl)
        {
            _smtpHost = smtpHost;
            _smtpPort = smtpPort;
            _smtpUsername = smtpUsername;
            _smtpPassword = smtpPassword;
            _fromEmail = fromEmail;
            _fromName = fromName;
            _enableSsl = enableSsl;
        }

        public async Task HandleEmailMessageAsync(EmailMessage emailMessage)
        {
            Console.ForegroundColor = ConsoleColor.Magenta;
            Console.WriteLine($"\n[RabbitMQ] Received email request for: {emailMessage.To} - {emailMessage.Subject}");
            Console.ResetColor();

            try
            {
                using var client = new SmtpClient(_smtpHost, _smtpPort);
                client.EnableSsl = _enableSsl;

                if (!string.IsNullOrEmpty(_smtpUsername))
                {
                    client.Credentials = new NetworkCredential(_smtpUsername, _smtpPassword);
                }
                else
                {
                    client.UseDefaultCredentials = false;
                }

                var message = new MailMessage
                {
                    From = new MailAddress(_fromEmail, _fromName),
                    Subject = emailMessage.Subject,
                    Body = emailMessage.HtmlBody,
                    IsBodyHtml = true
                };
                message.To.Add(emailMessage.To);

                await client.SendMailAsync(message);

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"[Email] Sent to {emailMessage.To}: {emailMessage.Subject}");
                Console.ResetColor();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"[Email Error] Failed to send to {emailMessage.To}: {ex.Message}");
                Console.ResetColor();
            }
        }
    }
}
