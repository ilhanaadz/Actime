namespace Actime.Services.Database
{
    public class Membership : SoftDeleteEntity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public DateTime StartDate { get; set; } = DateTime.Now;
        public DateTime? EndDate { get; set; }
        public int MembershipStatusId { get; set; }
       
        public virtual User User { get; set; } = null!;
        public virtual Organization Organization { get; set; } = null!;
        public virtual MembershipStatus MembershipStatus { get; set; } = null!;
    }
}
