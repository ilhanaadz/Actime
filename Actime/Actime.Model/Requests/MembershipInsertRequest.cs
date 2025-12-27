namespace Actime.Model.Requests
{
    public class MembershipInsertRequest
    {
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int MembershipStatusId { get; set; }
    }
}
