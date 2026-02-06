using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    [Authorize(Roles = "Admin")]
    [Route("api/[controller]")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IOrganizationService _organizationService;
        private readonly IEventService _eventService;

        public DashboardController(
            IUserService userService,
            IOrganizationService organizationService,
            IEventService eventService)
        {
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
            _organizationService = organizationService ?? throw new ArgumentNullException(nameof(organizationService));
            _eventService = eventService ?? throw new ArgumentNullException(nameof(eventService));
        }

        [HttpGet("stats")]
        public async Task<ActionResult> GetStats()
        {
            var users = await _userService.GetAsync(new Model.SearchObjects.UserSearchObject());
            var organizations = await _organizationService.GetAsync(new Model.SearchObjects.OrganizationSearchObject());
            var events = await _eventService.GetAsync(new Model.SearchObjects.EventSearchObject());

            var stats = new
            {
                TotalUsers = users.TotalCount,
                TotalOrganizations = organizations.TotalCount,
                TotalEvents = events.TotalCount
            };

            return Ok(stats);
        }

        [HttpGet("user-growth")]
        public async Task<ActionResult> GetUserGrowth([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var start = startDate ?? DateTime.Now.AddYears(-1);
            var end = endDate ?? DateTime.Now;

            var users = await _userService.GetAsync(new Model.SearchObjects.UserSearchObject());

            // Group users by month based on CreatedAt
            var growthData = users.Items
                .Where(u => u.CreatedAt >= start && u.CreatedAt <= end)
                .GroupBy(u => new { u.CreatedAt.Year, u.CreatedAt.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month)
                .Select(g => new
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("MMM yyyy"),
                    Count = g.Count()
                })
                .ToList();

            return Ok(growthData);
        }

        [HttpGet("organization-growth")]
        public async Task<ActionResult> GetOrganizationGrowth([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var start = startDate ?? DateTime.Now.AddYears(-1);
            var end = endDate ?? DateTime.Now;

            var organizations = await _organizationService.GetAsync(new Model.SearchObjects.OrganizationSearchObject());

            var growthData = organizations.Items
                .Where(o => o.CreatedAt >= start && o.CreatedAt <= end)
                .GroupBy(o => new { o.CreatedAt.Year, o.CreatedAt.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month)
                .Select(g => new
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("MMM yyyy"),
                    Count = g.Count()
                })
                .ToList();

            return Ok(growthData);
        }

        [HttpGet("event-growth")]
        public async Task<ActionResult> GetEventGrowth([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var start = startDate ?? DateTime.Now.AddYears(-1);
            var end = endDate ?? DateTime.Now;

            var events = await _eventService.GetAsync(new Model.SearchObjects.EventSearchObject());

            var growthData = events.Items
                .Where(e => e.CreatedAt >= start && e.CreatedAt <= end)
                .GroupBy(e => new { e.CreatedAt.Year, e.CreatedAt.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month)
                .Select(g => new
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("MMM yyyy"),
                    Count = g.Count()
                })
                .ToList();

            return Ok(growthData);
        }
    }
}
