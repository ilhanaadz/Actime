using Actime.Services.Database;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using EventMessage = Actime.Model.Entities.Event;
using DbNotification = Actime.Services.Database.Notification;

namespace Actime.Subscriber.Services
{
    public class EventNotificationHandler
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly SignalRConnectionManager _signalRManager;

        public EventNotificationHandler(IServiceProvider serviceProvider, SignalRConnectionManager signalRManager)
        {
            _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
            _signalRManager = signalRManager ?? throw new ArgumentNullException(nameof(signalRManager));
        }

        public async Task HandleEventCreatedAsync(EventMessage eventMessage)
        {
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine($"\n[RabbitMQ] Received: New event '{eventMessage.Title}' by {eventMessage.OrganizationName}");
            Console.ResetColor();

            try
            {
                using var scope = _serviceProvider.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<ActimeContext>();

                var organization = await context.Organizations
                    .AsNoTracking()
                    .FirstOrDefaultAsync(o => o.Id == eventMessage.OrganizationId);

                if (organization != null)
                {
                    await NotifyMembersAndFollowersAsync(context, organization, eventMessage);
                }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"[Success] Processed event: {eventMessage.Title}");
                Console.ResetColor();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"[Error] Failed to process event: {ex.Message}");
                Console.ResetColor();
            }
        }

        private async Task NotifyMembersAndFollowersAsync(ActimeContext context, Organization organization, EventMessage eventMessage)
        {
            var memberIds = await context.Memberships
                .Where(m => m.OrganizationId == eventMessage.OrganizationId && !m.IsDeleted)
                .Select(m => m.UserId)
                .ToListAsync();

            var followerIds = await context.Favorites
                .Where(f => f.EntityType == "Organization" && f.EntityId == eventMessage.OrganizationId)
                .Select(f => f.UserId)
                .ToListAsync();

            var notificationRecipients = memberIds
                .Concat(followerIds)
                .Where(userId => userId != organization.UserId)
                .Distinct()
                .ToList();

            Console.WriteLine($"[Info] Found {memberIds.Count} members and {followerIds.Count} followers for organization {organization.Name}");
            Console.WriteLine($"[Info] Total unique recipients (excluding owner): {notificationRecipients.Count}");

            foreach (var recipientId in notificationRecipients)
            {
                var recipientNotification = new DbNotification
                {
                    UserId = recipientId,
                    Message = $"Nova aktivnost od {eventMessage.OrganizationName}: {eventMessage.Title}",
                    IsRead = false,
                    CreatedAt = DateTime.Now
                };
                context.Notifications.Add(recipientNotification);
            }

            await context.SaveChangesAsync();
            Console.WriteLine($"[DB] Created {notificationRecipients.Count} in-app notifications for members/followers");

            await _signalRManager.Connection.InvokeAsync("SendToOrganizationFollowers",
                eventMessage.OrganizationId,
                new
                {
                    Type = "new_event",
                    Title = $"Nova aktivnost od {eventMessage.OrganizationName}",
                    Message = eventMessage.Title,
                    EventId = eventMessage.Id,
                    OrganizationId = eventMessage.OrganizationId,
                    Timestamp = DateTime.Now
                });

            Console.WriteLine($"[SignalR] Notified followers of org_{eventMessage.OrganizationId}");
        }
    }
}
