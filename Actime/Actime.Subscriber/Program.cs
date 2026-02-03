using Actime.Model.Entities;
using EasyNetQ;
using Microsoft.Extensions.DependencyInjection;

var services = new ServiceCollection();
services.AddEasyNetQ("host=localhost");

using var provider = services.BuildServiceProvider();
var bus = provider.GetRequiredService<IBus>();

await bus.PubSub.SubscribeAsync<Event>(
    "notification-service",
    HandleTextMessage
);

Console.WriteLine("Listening for messages. Hit <return> to quit.");
Console.ReadLine();

static Task HandleTextMessage(Event eventMessage)
{
    Console.ForegroundColor = ConsoleColor.Blue;
    Console.WriteLine(
        "New event created: {0}, {1}. Organized by {2}.",
        eventMessage.Title,
        eventMessage.Description,
        eventMessage.OrganizationName
    );
    Console.ResetColor();

    return Task.CompletedTask;
}