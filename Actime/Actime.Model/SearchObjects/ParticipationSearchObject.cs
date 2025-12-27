namespace Actime.Model.SearchObjects
{
    public class ParticipationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? EventId { get; set; }
        public int? AttendanceStatusId { get; set; }
        public int? PaymentMethodId { get; set; }
        public int? PaymentStatusId { get; set; }
        public DateTime? RegistrationDateFrom { get; set; }
        public DateTime? RegistrationDateTo { get; set; }
        public bool? HasPayment { get; set; }
        public bool IncludeDeleted { get; set; } = false;
    }
}
