using Actime.Model.Entities;
using Actime.Model.Settings;
using Actime.Services.Database;
using Actime.Subscriber.Services;
using EasyNetQ;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using EventMessage = Actime.Model.Entities.Event;

// Load .env file if exists (for local development)
var possibleEnvPaths = new[]
{
    Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".env"),  // From bin/Debug/net8.0
    Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"),              // From Actime.Subscriber folder
    Path.Combine(Directory.GetCurrentDirectory(), ".env")                      // Current directory
};

foreach (var envPath in possibleEnvPaths)
{
    var fullPath = Path.GetFullPath(envPath);
    if (File.Exists(fullPath))
    {
        DotNetEnv.Env.Load(fullPath);
        Console.WriteLine($"Loaded .env from: {fullPath}");
        break;
    }
}

var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables()
    .Build();

var services = new ServiceCollection();

services.AddDbContext<ActimeContext>(options =>
    options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

var rabbitMqSettings = configuration
    .GetSection("RabbitMqSettings")
    .Get<RabbitMqSettings>();

services.AddEasyNetQ(rabbitMqSettings!.GetConnectionString());

var provider = services.BuildServiceProvider();

var signalRUrl = configuration["SignalR:HubUrl"]
    ?? throw new InvalidOperationException("SignalR:HubUrl is not configured in appsettings.json");
var signalRManager = new SignalRConnectionManager(signalRUrl);
await signalRManager.ConnectAsync();

var eventNotificationHandler = new EventNotificationHandler(provider, signalRManager);
var membershipNotificationHandler = new MembershipNotificationHandler(provider, signalRManager);

var emailSettingsSection = configuration.GetSection("EmailSettings");
if (!emailSettingsSection.Exists())
{
    throw new InvalidOperationException("EmailSettings section is missing in appsettings.json");
}

var emailServiceHandler = new EmailServiceHandler(
    smtpHost: emailSettingsSection["SmtpHost"]!,
    smtpPort: int.Parse(emailSettingsSection["SmtpPort"]!),
    smtpUsername: emailSettingsSection["SmtpUsername"] ?? "",
    smtpPassword: emailSettingsSection["SmtpPassword"] ?? "",
    fromEmail: emailSettingsSection["FromEmail"]!,
    fromName: emailSettingsSection["FromName"]!,
    enableSsl: bool.Parse(emailSettingsSection["EnableSsl"]!)
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
