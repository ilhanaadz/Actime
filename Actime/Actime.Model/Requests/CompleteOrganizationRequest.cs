using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class CompleteOrganizationRequest
    {
        [Required(ErrorMessage = "Category is required")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Address is required")]
        public int AddressId { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        [StringLength(500), Url]
        public string? LogoUrl { get; set; }

        [Phone(ErrorMessage = "Invalid phone number")]
        public string? PhoneNumber { get; set; }
    }
}
