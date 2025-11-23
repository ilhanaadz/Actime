using Actime.Model.Entities;
using System.Security.Claims;

namespace Actime.Services.Interfaces
{
    public interface IJwtService
    {
        string GenerateAccessToken(Database.User user, IList<string> roles);
        string GenerateRefreshToken();
        ClaimsPrincipal? ValidateToken(string token);
    }
}
