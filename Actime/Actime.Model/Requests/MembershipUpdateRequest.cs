namespace Actime.Model.Requests
{
    public class MembershipUpdateRequest
    {
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int MembershipStatusId { get; set; }
    }
}
