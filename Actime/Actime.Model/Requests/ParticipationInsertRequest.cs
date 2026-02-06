using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class ParticipationInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Događaj je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite događaj")]
        public int EventId { get; set; }

        public DateTime RegistrationDate { get; set; } = DateTime.Now;

        [Required(ErrorMessage = "Status prisustva je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite status prisustva")]
        public int AttendanceStatusId { get; set; }

        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }
    }
}
