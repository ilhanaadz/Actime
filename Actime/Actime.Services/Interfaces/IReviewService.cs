using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IReviewService : ICrudService<Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        Task<List<Review>> GetOrganizationReviewsAsync(int organizationId);
        Task<double> GetOrganizationAverageScoreAsync(int organizationId);
        Task<List<Review>> GetUserReviewsAsync(int userId);
    }
}
