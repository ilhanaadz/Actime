using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Actime.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class ReviewController : BaseCrudController<Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService reviewService) : base(reviewService)
        {
            _reviewService = reviewService ?? throw new ArgumentNullException(nameof(reviewService));
        }

        [AllowAnonymous]
        [HttpGet("organization/{organizationId}")]
        public async Task<ActionResult<List<Review>>> GetOrganizationReviews(int organizationId)
        {
            var reviews = await _reviewService.GetOrganizationReviewsAsync(organizationId);
            return Ok(reviews);
        }

        [AllowAnonymous]
        [HttpGet("organization/{organizationId}/average")]
        public async Task<ActionResult<double>> GetOrganizationAverageScore(int organizationId)
        {
            var average = await _reviewService.GetOrganizationAverageScoreAsync(organizationId);
            return Ok(average);
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<Review>>> GetUserReviews(int userId)
        {
            var reviews = await _reviewService.GetUserReviewsAsync(userId);
            return Ok(reviews);
        }
    }
}