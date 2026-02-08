using Actime.Model.Entities;
using Actime.Services.Database;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using DbNotification = Actime.Services.Database.Notification;

namespace Actime.Subscriber.Services
{
    public class MembershipNotificationHandler
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly SignalRConnectionManager _signalRManager;

        public MembershipNotificationHandler(IServiceProvider serviceProvider, SignalRConnectionManager signalRManager)
        {
            _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
            _signalRManager = signalRManager ?? throw new ArgumentNullException(nameof(signalRManager));
        }

        public async Task HandleMembershipStatusChangeAsync(MembershipNotificationMessage message)
        {
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine($"\n[RabbitMQ] Received membership notification: User {message.UserId}, Org '{message.OrganizationName}', Status {message.MembershipStatusId}");
            Console.ResetColor();

            try
            {
                using var scope = _serviceProvider.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<ActimeContext>();

                string notificationMessage;
                string notificationType;

                if (message.MembershipStatusId == 2) // Approved
                {
                    notificationMessage = $"Your enrollment request for '{message.OrganizationName}' has been approved!";
                    notificationType = "enrollment_approved";
                }
                else if (message.MembershipStatusId == 3) // Rejected
                {
                    notificationMessage = $"Your enrollment request for '{message.OrganizationName}' has been rejected.";
                    notificationType = "enrollment_rejected";
                }
                else
                {
                    Console.WriteLine($"[Info] Skipping notification for status {message.MembershipStatusId}");
                    return;
                }

                var notification = new DbNotification
                {
                    UserId = message.UserId,
                    Message = notificationMessage,
                    IsRead = false,
                    CreatedAt = DateTime.Now
                };
                context.Notifications.Add(notification);
                await context.SaveChangesAsync();

                Console.WriteLine($"[DB] Created in-app notification for user {message.UserId}");

                await _signalRManager.Connection.InvokeAsync("SendToUser",
                    message.UserId,
                    new
                    {
                        Type = notificationType,
                        Title = "Nova notifikacija",
                        Message = notificationMessage,
                        OrganizationId = message.OrganizationId,
                        Timestamp = DateTime.Now
                    });

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"[SignalR] Sent notification to user_{message.UserId}");
                Console.WriteLine($"[Success] Processed membership notification");
                Console.ResetColor();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"[Error] Failed to process membership notification: {ex.Message}");
                Console.ResetColor();
            }
        }
    }
}
