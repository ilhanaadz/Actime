using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class EventUpdateRequest
    {
        [StringLength(200, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 200 znakova")]
        public string? Title { get; set; }

        [StringLength(2000, ErrorMessage = "Opis može imati maksimalno 2000 znakova")]
        public string? Description { get; set; }

        public DateTime? Start { get; set; }

        public DateTime? End { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Odaberite lokaciju")]
        public int? LocationId { get; set; }

        [Range(1, 10000, ErrorMessage = "Broj učesnika mora biti između 1 i 10000")]
        public int? MaxParticipants { get; set; }

        public bool? IsFree { get; set; }

        [Range(0, 100000, ErrorMessage = "Cijena mora biti između 0 i 100000")]
        public decimal? Price { get; set; }

        public int? EventStatusId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Odaberite tip aktivnosti")]
        public int? ActivityTypeId { get; set; }
    }
}