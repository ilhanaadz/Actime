using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IOrganizationService : IService<Organization, TextSearchObject>
    {
        Task<Organization> UpdateAsync(int organizationId, int userId, OrganizationUpdateRequest request);
        Task SoftDeleteAsync(int organizationId, int deletedByUserId);
        Task<bool> UserOwnsOrganizationAsync(int userId, int organizationId);
        Task<Organization?> GetByUserIdAsync(int userId);
        Task<Organization?> GetByIdForUserAsync(int organizationId, int? currentUserId);
        Task<PagedResult<EventParticipation>> GetOrganizationParticipationsAsync(int organizationId, int page = 1, int perPage = 10);
        Task<PagedResult<ParticipationByMonth>> GetOrganizationParticipationsByMonthAsync(int organizationId, int page = 1, int perPage = 10);
        Task<PagedResult<ParticipationByYear>> GetOrganizationParticipationsByYearAsync(int organizationId, int page = 1, int perPage = 10);
        Task<List<User>> GetParticipantsByMonthAsync(int organizationId, int month);
        Task<List<User>> GetParticipantsByYearAsync(int organizationId, int year);
    }
}
