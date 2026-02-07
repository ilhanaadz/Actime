using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IOrganizationService : IService<Organization, OrganizationSearchObject>
    {
        Task<Organization> UpdateAsync(int organizationId, int userId, OrganizationUpdateRequest request);
        Task SoftDeleteAsync(int organizationId, int deletedByUserId);
        Task<bool> UserOwnsOrganizationAsync(int userId, int organizationId);
        Task<Organization?> GetByUserIdAsync(int userId);
        Task<Organization?> GetByIdForUserAsync(int organizationId, int? currentUserId);
        Task<List<EventParticipation>> GetOrganizationParticipationsAsync(int organizationId);
        Task<List<ParticipationByMonth>> GetOrganizationParticipationsByMonthAsync(int organizationId);
        Task<List<ParticipationByYear>> GetOrganizationParticipationsByYearAsync(int organizationId);
        Task<List<User>> GetParticipantsByMonthAsync(int organizationId, int month);
        Task<List<User>> GetParticipantsByYearAsync(int organizationId, int year);
        Task<List<EnrollmentByMonth>> GetOrganizationEnrollmentsByMonthAsync(int organizationId);
        Task<List<EnrollmentByYear>> GetOrganizationEnrollmentsByYearAsync(int organizationId);
        Task<List<User>> GetMembersByMonthAsync(int organizationId, int month);
        Task<List<User>> GetMembersByYearAsync(int organizationId, int year);
    }
}
