namespace Actime.Model.Entities
{
    public class GalleryImage
    {
        public int Id { get; set; }
        public required string ImageUrl { get; set; }
        public string? Caption { get; set; }
        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
