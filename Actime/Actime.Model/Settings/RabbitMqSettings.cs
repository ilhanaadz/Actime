namespace Actime.Model.Settings
{
    public class RabbitMqSettings
    {
        public string Host { get; set; } = "localhost";
        public int Port { get; set; } = 5672;
        public string Username { get; set; } = "guest";
        public string Password { get; set; } = "guest";

        /// <summary>
        /// Returns the connection string in EasyNetQ format
        /// </summary>
        public string GetConnectionString()
        {
            return $"host={Host};port={Port};username={Username};password={Password}";
        }
    }
}
