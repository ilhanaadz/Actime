namespace Actime.Services.Database
{
    public class Report : SoftDeleteEntity
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public int ReportTypeId { get; set; }
        public required string ReportData { get; set; }
        //NOTE: Think if you need this.
        //public DateTime FromDate { get; set; }
        //public DateTime ToDate { get; set; }

        public virtual Organization Organization { get; set; } = null!;
    }
}
