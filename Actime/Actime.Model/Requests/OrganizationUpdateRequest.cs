using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class OrganizationUpdateRequest
    {
        [StringLength(200)]
        public string? Name { get; set; }

        [EmailAddress]
        public string? Email { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        [StringLength(500), Url]
        public string? LogoUrl { get; set; }

        [RegularExpression(@"^\+?[0-9\s\-]{8,15}$", ErrorMessage = "Invalid phone number format")]
        public string? PhoneNumber { get; set; }

        public int? CategoryId { get; set; }
        public int? AddressId { get; set; }
    }
}
