using Actime.Model.Entities;
using Actime.Model.Settings;
using Actime.Services.Database;
using Actime.Subscriber.Services;
using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using EventMessage = Actime.Model.Entities.Event;

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

var services = new ServiceCollection();

services.AddDbContext<ActimeContext>(options =>
    options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

var rabbitMqSettings = configuration.GetSection("RabbitMqSettings").Get<RabbitMqSettings>()
    ?? new RabbitMqSettings();
services.AddEasyNetQ(rabbitMqSettings.GetConnectionString());

var provider = services.BuildServiceProvider();

var signalRUrl = configuration["SignalR:HubUrl"] ?? "http://localhost:5171/notificationHub";
var signalRManager = new SignalRConnectionManager(signalRUrl);
await signalRManager.ConnectAsync();

var eventNotificationHandler = new EventNotificationHandler(provider, signalRManager);
var membershipNotificationHandler = new MembershipNotificationHandler(provider, signalRManager);

var emailSettings = configuration.GetSection("EmailSettings");
var emailServiceHandler = new EmailServiceHandler(
    smtpHost: emailSettings["SmtpHost"] ?? "localhost",
    smtpPort: int.Parse(emailSettings["SmtpPort"] ?? "1025"),
    smtpUsername: emailSettings["SmtpUsername"] ?? "",
    smtpPassword: emailSettings["SmtpPassword"] ?? "",
    fromEmail: emailSettings["FromEmail"] ?? "noreply@actime.com",
    fromName: emailSettings["FromName"] ?? "Actime",
    enableSsl: bool.Parse(emailSettings["EnableSsl"] ?? "false")
);

var bus = provider.GetRequiredService<IBus>();

await bus.PubSub.SubscribeAsync<EventMessage>(
    "notification-service",
    async eventMessage => await eventNotificationHandler.HandleEventCreatedAsync(eventMessage)
);

await bus.PubSub.SubscribeAsync<MembershipNotificationMessage>(
    "membership-notification-service",
    async membershipMessage => await membershipNotificationHandler.HandleMembershipStatusChangeAsync(membershipMessage)
);

await bus.PubSub.SubscribeAsync<EmailMessage>(
    "email-service",
    async emailMessage => await emailServiceHandler.HandleEmailMessageAsync(emailMessage)
);

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine("\n========================================");
Console.WriteLine("  Actime Notification Service Started");
Console.WriteLine("========================================");
Console.WriteLine("  Listening for RabbitMQ messages...");
Console.WriteLine("  - Event notifications (notification-service)");
Console.WriteLine("  - Membership notifications (membership-notification-service)");
Console.WriteLine("  - Email delivery (email-service)");
Console.WriteLine("  Press [Enter] to exit.");
Console.WriteLine("========================================\n");
Console.ResetColor();

Console.ReadLine();

await signalRManager.DisconnectAsync();
