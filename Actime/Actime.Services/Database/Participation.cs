namespace Actime.Services.Database
{
    public class Participation : SoftDeleteEntity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int EventId { get; set; }
        public DateTime RegistrationDate { get; set; } = DateTime.Now;
        public int PaymentMethodId { get; set; }
        public int PaymentStatusId { get; set; } //add table
        public int AttendanceStatusId { get; set; } //add table

        public virtual User User { get; set; } = null!;
        public virtual Event Event { get; set; } = null!;
    }
}
