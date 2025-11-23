using System.ComponentModel.DataAnnotations;
using System.Runtime.CompilerServices;

namespace Actime.Model.Requests
{
    public class RegisterRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Username is required")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]
        public required string Username { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public required string Email { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Password is required")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must have at least 6 characters")]
        public required string Password { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Password confirmation is required")]
        [Compare("Password", ErrorMessage = "Passwords do not match")]
        public required string ConfirmPassword { get; set; }

        public bool IsOrganization { get; set; } = false;

        public DateTime? DateOfBirth { get; set; }
    }
}