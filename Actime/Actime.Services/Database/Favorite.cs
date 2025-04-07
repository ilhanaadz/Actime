namespace Actime.Services.Database
{
    public class Favorite //Do I need base entity here at all? Probably not. 
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int EntityId { get; set; } //Can be organization or event, how to specify?
        public required string EntityType { get; set; } //Keep as basic string, add enum later which will represent Ev. and Org. options.

        public virtual User User { get; set; } = null!;
    }
}
