using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    [ApiController]
    [Route("api/recommendations")]
    public class RecommendationController : ControllerBase
    {
        private readonly IEventRecommenderService _recommender;

        public RecommendationController(IEventRecommenderService recommender)
        {
            _recommender = recommender;
        }

        [HttpGet("events/{userId}")]
        public IActionResult GetEventRecommendations(int userId, int top = 5)
        {
            var result = _recommender.RecommendEvents(userId, top);
            return Ok(result);
        }
    }
}
