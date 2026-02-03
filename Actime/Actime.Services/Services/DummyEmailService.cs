using Actime.Services.Interfaces;
using Microsoft.Extensions.Logging;

namespace Actime.Services.Services
{
    public class DummyEmailService : IEmailService
    {
        private readonly ILogger<DummyEmailService> _logger;

        public DummyEmailService(ILogger<DummyEmailService> logger)
        {
            _logger = logger;
        }

        public Task SendEmailConfirmationAsync(string email, string userName, string confirmationLink)
        {
            LogEmail(
                email,
                "Confirm your email - Actime",
                $"Confirmation link: {confirmationLink}"
            );

            return Task.CompletedTask;
        }

        public Task SendPasswordResetAsync(string email, string userName, string resetLink)
        {
            LogEmail(
                email,
                "Reset your password - Actime",
                $"Reset link: {resetLink}"
            );

            return Task.CompletedTask;
        }

        public Task SendWelcomeEmailAsync(string email, string userName)
        {
            LogEmail(
                email,
                "Welcome to Actime!",
                $"Welcome email for {userName}"
            );

            return Task.CompletedTask;
        }

        public Task SendOrganizationWelcomeEmailAsync(string email, string userName, string organizationName)
        {
            LogEmail(
                email,
                "Organization created - Actime",
                $"Organization '{organizationName}' created for {userName}"
            );

            return Task.CompletedTask;
        }

        private void LogEmail(string to, string subject, string content)
        {
            _logger.LogInformation("""
            ==============================
            DUMMY EMAIL SENT
            To: {To}
            Subject: {Subject}
            Content: {Content}
            ==============================
            """, to, subject, content);
        }
    }
}
