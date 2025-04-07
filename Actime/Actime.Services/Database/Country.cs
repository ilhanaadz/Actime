using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public  class Country
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public string? Code { get; set; }
        
        public virtual ICollection<City> Cities { get; set; } = new HashSet<City>(); //NOTE: Check this.
    }
}
