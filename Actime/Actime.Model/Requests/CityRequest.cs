using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class CityRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "City name is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Country ID is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Country ID must be greater than 0")]
        public int CountryId { get; set; }
    }
}
