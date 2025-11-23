using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Interfaces
{
    public interface IEmailService
    {
        Task SendEmailConfirmationAsync(string email, string userName, string confirmationLink);
        Task SendPasswordResetAsync(string email, string userName, string resetLink);
        Task SendWelcomeEmailAsync(string email, string userName);
        Task SendOrganizationWelcomeEmailAsync(string email, string userName, string organizationName);
    }
}
