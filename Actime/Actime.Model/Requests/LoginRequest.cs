using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class LoginRequest
    {
        [Required(ErrorMessage = "Email ili korisničko ime je obavezno")]
        public required string EmailOrUsername { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Lozinka je obavezna")]
        public required string Password { get; set; }
    }
}
