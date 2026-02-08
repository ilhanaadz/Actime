namespace Actime.Model.Settings
{
    public class RabbitMqSettings
    {
        public required string Host { get; set; }
        public int Port { get; set; }
        public required string Username { get; set; }
        public required string Password { get; set; }

        public string GetConnectionString()
        {
            return $"host={Host};port={Port};username={Username};password={Password}";
        }
    }
}
