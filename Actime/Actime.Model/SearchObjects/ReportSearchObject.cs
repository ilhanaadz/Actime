namespace Actime.Model.SearchObjects
{
    public class ReportSearchObject : BaseSearchObject
    {
        public int? OrganizationId { get; set; }
        public int? ReportTypeId { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public bool IncludeDeleted { get; set; } = false;
    }
}
