using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Services.Database
{
    public class PaymentMethod : SoftDeleteEntity
    {
        public int Id { get; set; }
        public required string Name { get; set; }
    }
}
