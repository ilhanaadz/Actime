using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public class Location
    {
        public int Id { get; set; }
        public required string Address { get; set; } //NOTE: Use address table, or delete it.
        public int CityId { get; set; }
        public string? Coordinates { get; set; }
        public int? Capacity { get; set; }
        public string? Description { get; set; }
        public string? ContactInfo { get; set; }

        public virtual City City { get; set; } = null!;
    }
}
