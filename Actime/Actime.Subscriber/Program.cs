using Actime.Model.Entities;
using Actime.Model.Settings;
using Actime.Services.Database;
using EasyNetQ;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Net;
using System.Net.Mail;
using EventMessage = Actime.Model.Entities.Event;
using DbNotification = Actime.Services.Database.Notification;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

var services = new ServiceCollection();

services.AddDbContext<ActimeContext>(options =>
    options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

// RabbitMQ configuration
var rabbitMqSettings = configuration.GetSection("RabbitMqSettings").Get<RabbitMqSettings>()
    ?? new RabbitMqSettings();
services.AddEasyNetQ(rabbitMqSettings.GetConnectionString());

using var provider = services.BuildServiceProvider();

var signalRUrl = configuration["SignalR:HubUrl"] ?? "http://localhost:5171/notificationHub";
var hubConnection = new HubConnectionBuilder()
    .WithUrl(signalRUrl)
    .WithAutomaticReconnect()
    .Build();

async Task ConnectToSignalR()
{
    while (true)
    {
        try
        {
            await hubConnection.StartAsync();
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"[SignalR] Connected to {signalRUrl}");
            Console.ResetColor();
            break;
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"[SignalR] Connection failed: {ex.Message}. Retrying in 5 seconds...");
            Console.ResetColor();
            await Task.Delay(5000);
        }
    }
}

hubConnection.Closed += async (error) =>
{
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine($"[SignalR] Connection closed. Reconnecting...");
    Console.ResetColor();
    await Task.Delay(2000);
    await ConnectToSignalR();
};

await ConnectToSignalR();

var bus = provider.GetRequiredService<IBus>();

await bus.PubSub.SubscribeAsync<EventMessage>(
    "notification-service",
    async eventMessage =>
    {
        Console.ForegroundColor = ConsoleColor.Blue;
        Console.WriteLine($"\n[RabbitMQ] Received: New event '{eventMessage.Title}' by {eventMessage.OrganizationName}");
        Console.ResetColor();

        try
        {
            using var scope = provider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ActimeContext>();

            var organization = await context.Organizations
                .AsNoTracking()
                .FirstOrDefaultAsync(o => o.Id == eventMessage.OrganizationId);

            if (organization != null)
            {
                var ownerNotification = new DbNotification
                {
                    UserId = organization.UserId,
                    Message = $"Vaš event \"{eventMessage.Title}\" je uspješno kreiran i objavljen.",
                    IsRead = false,
                    CreatedAt = DateTime.Now
                };
                context.Notifications.Add(ownerNotification);

                await hubConnection.InvokeAsync("SendToUser",
                    organization.UserId,
                    new
                    {
                        Type = "event_created",
                        Title = "Event kreiran",
                        Message = $"Vaš event \"{eventMessage.Title}\" je uspješno objavljen!",
                        EventId = eventMessage.Id,
                        Timestamp = DateTime.Now
                    });
                Console.WriteLine($"[SignalR] Notified owner (UserId: {organization.UserId})");

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
                Console.WriteLine($"[DB] Created {notificationRecipients.Count + 1} in-app notifications (1 owner + {notificationRecipients.Count} members/followers)");

                await hubConnection.InvokeAsync("SendToOrganizationFollowers",
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
);

// Email Service - Subscribe to EmailMessage
var emailSettings = configuration.GetSection("EmailSettings");
var smtpHost = emailSettings["SmtpHost"] ?? "localhost";
var smtpPort = int.Parse(emailSettings["SmtpPort"] ?? "1025");
var smtpUsername = emailSettings["SmtpUsername"] ?? "";
var smtpPassword = emailSettings["SmtpPassword"] ?? "";
var fromEmail = emailSettings["FromEmail"] ?? "noreply@actime.com";
var fromName = emailSettings["FromName"] ?? "Actime";
var enableSsl = bool.Parse(emailSettings["EnableSsl"] ?? "false");

await bus.PubSub.SubscribeAsync<EmailMessage>(
    "email-service",
    async emailMessage =>
    {
        Console.ForegroundColor = ConsoleColor.Magenta;
        Console.WriteLine($"\n[RabbitMQ] Received email request for: {emailMessage.To} - {emailMessage.Subject}");
        Console.ResetColor();

        try
        {
            using var client = new SmtpClient(smtpHost, smtpPort);
            client.EnableSsl = enableSsl;

            if (!string.IsNullOrEmpty(smtpUsername))
            {
                client.Credentials = new NetworkCredential(smtpUsername, smtpPassword);
            }
            else
            {
                client.UseDefaultCredentials = false;
            }

            var message = new MailMessage
            {
                From = new MailAddress(fromEmail, fromName),
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
);

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine("\n========================================");
Console.WriteLine("  Actime Notification Service Started");
Console.WriteLine("========================================");
Console.WriteLine("  Listening for RabbitMQ messages...");
Console.WriteLine("  - Event notifications (notification-service)");
Console.WriteLine("  - Email delivery (email-service)");
Console.WriteLine("  Press [Enter] to exit.");
Console.WriteLine("========================================\n");
Console.ResetColor();

Console.ReadLine();

await hubConnection.StopAsync();
