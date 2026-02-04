using Actime.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Actime.Model.Responses
{
    public class AuthResponse
    {
        public int UserId { get; set; }
        public string Email { get; set; } = null!;
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string AccessToken { get; set; } = null!;
        public string RefreshToken { get; set; } = null!;
        public DateTime ExpiresAt { get; set; }
        public List<string> Roles { get; set; } = new();
        public bool RequiresOrganizationSetup { get; set; }
        public Organization? Organization { get; set; }
        public string? ProfileImageUrl { get; set; }
    }
}
