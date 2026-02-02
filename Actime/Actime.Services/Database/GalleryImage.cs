namespace Actime.Services.Database
{
    public class GalleryImage : SoftDeleteEntity
    {
        public required string ImageUrl { get; set; }
        public string? Caption { get; set; }

        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }

        public virtual User? User { get; set; }
        public virtual Organization? Organization { get; set; }
    }
}
