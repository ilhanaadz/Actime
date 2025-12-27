namespace Actime.Model.Requests
{
    public class ParticipationUpdateRequest
    {
        public DateTime RegistrationDate { get; set; }
        public int AttendanceStatusId { get; set; }
        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }
    }
}
