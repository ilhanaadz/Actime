using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IUserService : IService<User, TextSearchObject>
    {
        Task<User> UpdateAsync(int userId, UserUpdateRequest request);
        Task SoftDeleteAsync(int userId, int deletedByUserId);
        Task<bool> ExistsAsync(int userId);
    }
}
