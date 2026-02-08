using Microsoft.AspNetCore.SignalR.Client;

namespace Actime.Subscriber.Services
{
    public class SignalRConnectionManager
    {
        private readonly HubConnection _hubConnection;
        private readonly string _hubUrl;

        public SignalRConnectionManager(string hubUrl)
        {
            _hubUrl = hubUrl;
            _hubConnection = new HubConnectionBuilder()
                .WithUrl(hubUrl)
                .WithAutomaticReconnect()
                .Build();

            _hubConnection.Closed += OnConnectionClosed;
        }

        public HubConnection Connection => _hubConnection;

        public async Task ConnectAsync()
        {
            while (true)
            {
                try
                {
                    await _hubConnection.StartAsync();
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine($"[SignalR] Connected to {_hubUrl}");
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

        public async Task DisconnectAsync()
        {
            await _hubConnection.StopAsync();
        }

        private async Task OnConnectionClosed(Exception? error)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"[SignalR] Connection closed. Reconnecting...");
            Console.ResetColor();
            await Task.Delay(2000);
            await ConnectAsync();
        }
    }
}
