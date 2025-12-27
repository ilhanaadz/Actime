namespace Actime.Model.Entities
{
    public class Participation
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int EventId { get; set; }
        public DateTime RegistrationDate { get; set; }
        public int AttendanceStatusId { get; set; }
        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}
