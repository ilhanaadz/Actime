using Actime.Services.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Services
{
    public class EmailService : IEmailService
    {
        private readonly EmailSettings _settings;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IOptions<EmailSettings> settings, ILogger<EmailService> logger)
        {
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task SendEmailConfirmationAsync(string email, string userName, string confirmationLink)
        {
            var subject = "Confirm your email - Actime";
            var body = $@"
            <h2>Welcome to Actime, {userName}!</h2>
            <p>Please confirm your email address by clicking the link below:</p>
            <p><a href='{confirmationLink}' style='background-color: #008080; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Confirm Email</a></p>
            <p>Or copy this link: {confirmationLink}</p>
            <p>This link will expire in 24 hours.</p>
            <br/>
            <p>If you didn't create an account, please ignore this email.</p>
        ";

            await SendEmailAsync(email, subject, body);
        }

        public async Task SendPasswordResetAsync(string email, string userName, string resetLink)
        {
            var subject = "Reset your password - Actime";
            var body = $@"
            <h2>Password Reset Request</h2>
            <p>Hi {userName},</p>
            <p>We received a request to reset your password. Click the link below to create a new password:</p>
            <p><a href='{resetLink}' style='background-color: #008080; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Reset Password</a></p>
            <p>Or copy this link: {resetLink}</p>
            <p>This link will expire in 1 hour.</p>
            <br/>
            <p>If you didn't request a password reset, please ignore this email.</p>
        ";

            await SendEmailAsync(email, subject, body);
        }

        public async Task SendWelcomeEmailAsync(string email, string userName)
        {
            var subject = "Welcome to Actime!";
            var body = $@"
            <h2>Welcome to Actime, {userName}!</h2>
            <p>Your account has been successfully created.</p>
            <p>You can now explore events and organizations in your area.</p>
            <br/>
            <p>Best regards,<br/>The Actime Team</p>
        ";

            await SendEmailAsync(email, subject, body);
        }

        public async Task SendOrganizationWelcomeEmailAsync(string email, string userName, string organizationName)
        {
            var subject = "Your organization is ready - Actime";
            var body = $@"
            <h2>Congratulations, {userName}!</h2>
            <p>Your organization <strong>{organizationName}</strong> has been successfully created on Actime.</p>
            <p>You can now:</p>
            <ul>
                <li>Create and manage events</li>
                <li>Accept memberships</li>
                <li>Engage with your community</li>
            </ul>
            <br/>
            <p>Best regards,<br/>The Actime Team</p>
        ";

            await SendEmailAsync(email, subject, body);
        }

        private async Task SendEmailAsync(string to, string subject, string htmlBody)
        {
            try
            {
                using var client = new SmtpClient(_settings.SmtpHost, _settings.SmtpPort);
                client.EnableSsl = _settings.EnableSsl;
                client.Credentials = new NetworkCredential(_settings.SmtpUsername, _settings.SmtpPassword);

                var message = new MailMessage
                {
                    From = new MailAddress(_settings.FromEmail, _settings.FromName),
                    Subject = subject,
                    Body = htmlBody,
                    IsBodyHtml = true
                };
                message.To.Add(to);

                await client.SendMailAsync(message);
                _logger.LogInformation("Email sent to {Email} with subject: {Subject}", to, subject);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {Email}", to);
                // Ne bacaj exception - email failure ne bi trebao blokirati flow
            }
        }
    }

    public class EmailSettings
    {
        public string SmtpHost { get; set; } = null!;
        public int SmtpPort { get; set; }
        public string SmtpUsername { get; set; } = null!;
        public string SmtpPassword { get; set; } = null!;
        public string FromEmail { get; set; } = null!;
        public string FromName { get; set; } = null!;
        public bool EnableSsl { get; set; } = true;
        public string FrontendBaseUrl { get; set; } = null!; // Za linkove u emailovima
    }
}