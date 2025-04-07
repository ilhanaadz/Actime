using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public class Address
    {
        public int Id { get; set; }
        public required string Street { get; set; }
        public int CityId { get; set; } //NOTE: If this table will be used, it should be a foreign key to the city table.
        public required string PostalCode { get; set; }
        public string? Coordinates { get; set; }
    }
}
