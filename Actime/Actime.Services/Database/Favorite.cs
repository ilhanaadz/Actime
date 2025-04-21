namespace Actime.Services.Database
{
    public class Favorite 
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int EntityId { get; set; } 
        public required string EntityType { get; set; }

        public virtual User User { get; set; } = null!;
    }
}
