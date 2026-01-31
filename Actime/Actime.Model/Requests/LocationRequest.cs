using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class LocationRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Name is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Address is required")]
        [Range(1, int.MaxValue)]
        public int AddressId { get; set; }

        public int? Capacity { get; set; }

        public string? Description { get; set; }

        public string? ContactInfo { get; set; }
    }
}