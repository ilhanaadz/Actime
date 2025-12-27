namespace Actime.Model.Requests
{
    public class FavoriteUpdateRequest
    {
        public int EntityId { get; set; }
        public required string EntityType { get; set; }
    }
}
