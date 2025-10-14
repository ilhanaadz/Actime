using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class AddressRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Street is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Street must be between 2 and 100 characters")]
        public required string Street { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Postal code is required")]
        [StringLength(20, MinimumLength = 1, ErrorMessage = "Check postal code length")]
        public required string PostalCode { get; set; }

        [Required(ErrorMessage = "City ID is required")]
        [Range(1, int.MaxValue, ErrorMessage = "City ID must be greater than 0")]
        public int CityId { get; set; }
    }
}
