using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class CompleteOrganizationRequest
    {
        [Required(ErrorMessage = "Kategorija je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite kategoriju")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Adresa je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite adresu")]
        public int AddressId { get; set; }

        [StringLength(500, ErrorMessage = "Opis može imati maksimalno 500 znakova")]
        public string? Description { get; set; }

        [StringLength(500), Url(ErrorMessage = "Unesite validan URL")]
        public string? LogoUrl { get; set; }

        [RegularExpression(@"^\+?[0-9\s\-]{8,15}$", ErrorMessage = "Unesite validan broj telefona (8-15 cifara)")]
        public string? PhoneNumber { get; set; }
    }
}
