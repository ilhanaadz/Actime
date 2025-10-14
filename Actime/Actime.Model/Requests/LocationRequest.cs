using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class LocationRequest
    {
        [Required(ErrorMessage = "Address is required")]
        [Range(1, int.MaxValue)]
        public int AddressId { get; set; }

        public int? Capacity { get; set; }

        public string? Description { get; set; }

        public string? ContactInfo { get; set; }
    }
}