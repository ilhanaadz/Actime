namespace Actime.Model.Entities
{
    public class Report
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int ReportTypeId { get; set; }
        public required string ReportData { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; }
    }
}
