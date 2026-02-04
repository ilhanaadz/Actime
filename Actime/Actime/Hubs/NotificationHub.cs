using Microsoft.AspNetCore.SignalR;

namespace Actime.Hubs
{
    public class NotificationHub : Hub
    {
        private static readonly Dictionary<int, HashSet<string>> _userConnections = new();
        private static readonly object _lock = new();

        /// <summary>
        /// Registers user connection for targeted notifications
        /// </summary>
        public async Task RegisterUser(int userId)
        {
            lock (_lock)
            {
                if (!_userConnections.ContainsKey(userId))
                {
                    _userConnections[userId] = new HashSet<string>();
                }
                _userConnections[userId].Add(Context.ConnectionId);
            }

            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
            Console.WriteLine($"User {userId} connected with ConnectionId: {Context.ConnectionId}");
        }

        /// <summary>
        /// Subscribes to organization notifications
        /// </summary>
        public async Task SubscribeToOrganization(int organizationId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"org_{organizationId}");
            Console.WriteLine($"Connection {Context.ConnectionId} subscribed to org_{organizationId}");
        }

        /// <summary>
        /// Unsubscribes from organization notifications
        /// </summary>
        public async Task UnsubscribeFromOrganization(int organizationId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"org_{organizationId}");
            Console.WriteLine($"Connection {Context.ConnectionId} unsubscribed from org_{organizationId}");
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            lock (_lock)
            {
                foreach (var userConnections in _userConnections.Values)
                {
                    userConnections.Remove(Context.ConnectionId);
                }

                // Cleanup empty entries
                var emptyUsers = _userConnections.Where(x => x.Value.Count == 0).Select(x => x.Key).ToList();
                foreach (var userId in emptyUsers)
                {
                    _userConnections.Remove(userId);
                }
            }

            Console.WriteLine($"Connection {Context.ConnectionId} disconnected");
            await base.OnDisconnectedAsync(exception);
        }

        /// <summary>
        /// Gets connection IDs for a specific user
        /// </summary>
        public static List<string> GetUserConnections(int userId)
        {
            lock (_lock)
            {
                if (_userConnections.TryGetValue(userId, out var connections))
                {
                    return connections.ToList();
                }
                return new List<string>();
            }
        }

        /// <summary>
        /// Sends notification to a specific user (called from Subscriber)
        /// </summary>
        public async Task SendToUser(int userId, object notification)
        {
            await Clients.Group($"user_{userId}").SendAsync("ReceiveNotification", notification);
            Console.WriteLine($"[Hub] Sent notification to user_{userId}");
        }

        /// <summary>
        /// Sends notification to all followers of an organization (called from Subscriber)
        /// </summary>
        public async Task SendToOrganizationFollowers(int organizationId, object notification)
        {
            await Clients.Group($"org_{organizationId}").SendAsync("ReceiveNotification", notification);
            Console.WriteLine($"[Hub] Sent notification to org_{organizationId} followers");
        }

        /// <summary>
        /// Broadcasts notification to all connected clients
        /// </summary>
        public async Task BroadcastNotification(object notification)
        {
            await Clients.All.SendAsync("ReceiveNotification", notification);
            Console.WriteLine("[Hub] Broadcasted notification to all clients");
        }
    }
}
