using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public class Schedule
    {
        public int Id { get; set; }
        public int OrganizationId { get; set; }
        public required string DayOfWeek { get; set; }
        public TimeOnly? StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public int ActivityTypeId { get; set; } //NOTE: Add activity type table and object
        public string? Description { get; set; }
        public int LocationId { get; set; }
        
        public virtual Organization Organization { get; set; } = null!;
    }
}
