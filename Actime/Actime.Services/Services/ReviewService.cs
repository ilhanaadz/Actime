using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class ReviewService : BaseCrudService<Model.Entities.Review, ReviewSearchObject, Database.Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.OrganizationId.HasValue)
            {
                query = query.Where(x => x.OrganizationId == search.OrganizationId.Value);
            }

            if (search.MinScore.HasValue)
            {
                query = query.Where(x => x.Score >= search.MinScore.Value);
            }

            if (search.MaxScore.HasValue)
            {
                query = query.Where(x => x.Score <= search.MaxScore.Value);
            }

            if (search.CreatedFrom.HasValue)
            {
                query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);
            }

            if (search.CreatedTo.HasValue)
            {
                query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);
            }

            if (search.HasText.HasValue)
            {
                if (search.HasText.Value)
                {
                    query = query.Where(x => !string.IsNullOrEmpty(x.Text));
                }
                else
                {
                    query = query.Where(x => string.IsNullOrEmpty(x.Text));
                }
            }

            query = query.OrderByDescending(x => x.CreatedAt);

            return base.ApplyFilter(query, search);
        }

        protected override Task OnCreating(Review entity, ReviewInsertRequest request)
        {
            entity.CreatedAt = DateTime.Now;

            if (entity.Score < 1 || entity.Score > 5)
            {
                throw new ArgumentException("Score has to be between 1 and 5.");
            }

            return Task.CompletedTask;
        }

        protected override Task OnUpdating(Review entity, ReviewUpdateRequest request)
        {
            if (request.Score < 1 || request.Score > 5)
            {
                throw new ArgumentException("Score has to be between 1 and 5.");
            }

            return Task.CompletedTask;
        }

        public async Task<List<Model.Entities.Review>> GetOrganizationReviewsAsync(int organizationId)
        {
            var reviews = await _context.Set<Review>()
                .Where(x => x.OrganizationId == organizationId)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Review>>(reviews);
        }

        public async Task<double> GetOrganizationAverageScoreAsync(int organizationId)
        {
            var reviews = await _context.Set<Review>()
                .Where(x => x.OrganizationId == organizationId)
                .ToListAsync();

            if (!reviews.Any())
                return 0;

            return reviews.Average(x => x.Score);
        }

        public async Task<List<Model.Entities.Review>> GetUserReviewsAsync(int userId)
        {
            var reviews = await _context.Set<Review>()
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Review>>(reviews);
        }
    }
}