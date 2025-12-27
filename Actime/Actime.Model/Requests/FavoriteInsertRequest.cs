namespace Actime.Model.Requests
{
    public class FavoriteInsertRequest
    {
        public int UserId { get; set; }
        public int EntityId { get; set; }
        public required string EntityType { get; set; }
    }
}
