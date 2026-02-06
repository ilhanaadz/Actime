using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class MembershipInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Organizacija je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite organizaciju")]
        public int OrganizationId { get; set; }

        [Required(ErrorMessage = "Datum početka je obavezan")]
        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [Required(ErrorMessage = "Status članstva je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite status članstva")]
        public int MembershipStatusId { get; set; }
    }
}
