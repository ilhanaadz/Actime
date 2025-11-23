using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class UserUpdateRequest
    {
        [StringLength(100)]
        public string? FirstName { get; set; }

        [StringLength(100)]
        public string? LastName { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [Url]
        public string? ProfileImageUrl { get; set; }
    }
}
