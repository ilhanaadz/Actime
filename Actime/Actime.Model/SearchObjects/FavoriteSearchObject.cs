namespace Actime.Model.SearchObjects
{
    public class FavoriteSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? EntityId { get; set; }
        public string? EntityType { get; set; }
    }
}
