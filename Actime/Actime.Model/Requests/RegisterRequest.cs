using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class RegisterRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Korisničko ime je obavezno")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Korisničko ime mora imati između 3 i 50 znakova")]
        [RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Korisničko ime može sadržavati samo slova, brojeve i donju crtu")]
        public required string Username { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Email je obavezan")]
        [EmailAddress(ErrorMessage = "Unesite validnu email adresu (npr. korisnik@primjer.com)")]
        public required string Email { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Lozinka je obavezna")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati najmanje 6 znakova")]
        public required string Password { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Potvrda lozinke je obavezna")]
        [Compare("Password", ErrorMessage = "Lozinke se ne podudaraju")]
        public required string ConfirmPassword { get; set; }

        public bool IsOrganization { get; set; } = false;

        public DateTime? DateOfBirth { get; set; }
    }
}