using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public class Organization : SoftDeleteEntity
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public int CategoryId { get; set; } //Add category obj
        public int AddressId { get; set; }
    }
}