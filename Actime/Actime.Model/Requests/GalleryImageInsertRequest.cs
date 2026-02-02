namespace Actime.Model.Requests
{
    public class GalleryImageInsertRequest
    {
        public required string ImageUrl { get; set; }
        public string? Caption { get; set; }
        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
    }
}
