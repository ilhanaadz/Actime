using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class GalleryImageInsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "URL slike je obavezan")]
        [Url(ErrorMessage = "Unesite validan URL slike")]
        public required string ImageUrl { get; set; }

        [StringLength(500, ErrorMessage = "Opis može imati maksimalno 500 znakova")]
        public string? Caption { get; set; }

        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
    }
}
