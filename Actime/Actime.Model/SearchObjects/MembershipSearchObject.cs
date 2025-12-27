namespace Actime.Model.SearchObjects
{
    public class MembershipSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
        public int? MembershipStatusId { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public DateTime? EndDateFrom { get; set; }
        public DateTime? EndDateTo { get; set; }
        public bool? IsActive { get; set; }
        public bool IncludeDeleted { get; set; } = false;
    }
}
