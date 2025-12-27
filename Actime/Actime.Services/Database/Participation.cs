namespace Actime.Services.Database
{
    public class Participation : SoftDeleteEntity
    {
        public int UserId { get; set; }
        public int EventId { get; set; }
        public DateTime RegistrationDate { get; set; } = DateTime.Now;
        public int AttendanceStatusId { get; set; }
        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }

        public virtual User User { get; set; } = null!;
        public virtual Event Event { get; set; } = null!;
        public virtual AttendanceStatus AttendanceStatus { get; set; } = null!;
        public virtual PaymentMethod? PaymentMethod { get; set; }
        public virtual PaymentStatus? PaymentStatus { get; set; }
    }
}
