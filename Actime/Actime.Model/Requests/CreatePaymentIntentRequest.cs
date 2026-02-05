using System.ComponentModel.DataAnnotations;

namespace Actime.Model.Requests
{
    public class CreatePaymentIntentRequest
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int EventId { get; set; }
    }
}
