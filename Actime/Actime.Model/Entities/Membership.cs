namespace Actime.Model.Entities
{
    public class Membership
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int MembershipStatusId { get; set; }
        public bool IsDeleted { get; set; }
    }
}
