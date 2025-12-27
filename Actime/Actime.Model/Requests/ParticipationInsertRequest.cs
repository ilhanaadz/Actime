namespace Actime.Model.Requests
{
    public class ParticipationInsertRequest
    {
        public int UserId { get; set; }
        public int EventId { get; set; }
        public DateTime RegistrationDate { get; set; } = DateTime.Now;
        public int AttendanceStatusId { get; set; }
        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }
    }
}
