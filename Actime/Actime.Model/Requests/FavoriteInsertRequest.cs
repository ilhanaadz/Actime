using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class FavoriteInsertRequest
    {
        [Required(ErrorMessage = "Korisnik je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite korisnika")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Entitet je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Odaberite entitet")]
        public int EntityId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Tip entiteta je obavezan")]
        [StringLength(50, ErrorMessage = "Tip entiteta može imati maksimalno 50 znakova")]
        public required string EntityType { get; set; }
    }
}
