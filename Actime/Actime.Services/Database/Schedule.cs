namespace Actime.Services.Database
{
    public class Schedule
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public required string DayOfWeek { get; set; }
        public TimeOnly? StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public int ActivityTypeId { get; set; }
        public string? Description { get; set; }
        public int LocationId { get; set; }
        
        public virtual Organization Organization { get; set; } = null!;
        public virtual ActivityType ActivityType { get; set; } = null!;
        public virtual Location Location { get; set; } = null!;
    }
}
