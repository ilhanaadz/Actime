using Actime.Model.Constants;
using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class EventInsertRequest
    {
        [Required(ErrorMessage = "Organizacija je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite organizaciju")]
        public int OrganizationId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Naziv događaja je obavezan")]
        [StringLength(200, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 200 znakova")]
        public required string Title { get; set; }

        [StringLength(2000, ErrorMessage = "Opis može imati maksimalno 2000 znakova")]
        public string? Description { get; set; }

        [Required(ErrorMessage = "Datum početka je obavezan")]
        public DateTime Start { get; set; }

        [Required(ErrorMessage = "Datum završetka je obavezan")]
        public DateTime End { get; set; }

        [Required(ErrorMessage = "Lokacija je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite lokaciju")]
        public int LocationId { get; set; }

        [Range(1, 10000, ErrorMessage = "Broj učesnika mora biti između 1 i 10000")]
        public int? MaxParticipants { get; set; }

        public bool IsFree { get; set; }

        [Range(0, 100000, ErrorMessage = "Cijena mora biti između 0 i 100000")]
        public decimal Price { get; set; }

        [Required(ErrorMessage = "Tip aktivnosti je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite tip aktivnosti")]
        public int ActivityTypeId { get; set; }

        /// <summary>
        /// Event status. Defaults to Pending if not specified.
        /// </summary>
        public int EventStatusId { get; set; } = (int)EventStatus.Pending;
    }
}
