using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class LoginRequest
    {
        [Required(ErrorMessage = "Email je obavezan")]
        [EmailAddress(ErrorMessage = "Unesite validnu email adresu (npr. korisnik@primjer.com)")]
        public required string Email { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Lozinka je obavezna")]
        public required string Password { get; set; }
    }
}
