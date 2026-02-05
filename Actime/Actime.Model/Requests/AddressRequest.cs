using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class AddressRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ulica je obavezna")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Ulica mora imati između 2 i 100 znakova")]
        public required string Street { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Poštanski broj je obavezan")]
        [StringLength(20, MinimumLength = 1, ErrorMessage = "Provjerite dužinu poštanskog broja")]
        public required string PostalCode { get; set; }

        [Required(ErrorMessage = "Grad je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite grad")]
        public int CityId { get; set; }

        public string? Coordinates { get; set; }
    }
}
