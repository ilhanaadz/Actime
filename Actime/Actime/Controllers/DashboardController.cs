using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    [Authorize(Roles = "Admin")]
    [Route("[controller]")]
    [ApiController]
    public class DashboardController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IOrganizationService _organizationService;
        private readonly IEventService _eventService;
        private readonly IMembershipService _membershipService;
        private readonly IParticipationService _participationService;

        public DashboardController(
            IUserService userService,
            IOrganizationService organizationService,
            IEventService eventService,
            IMembershipService membershipService,
            IParticipationService participationService)
        {
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
            _organizationService = organizationService ?? throw new ArgumentNullException(nameof(organizationService));
            _eventService = eventService ?? throw new ArgumentNullException(nameof(eventService));
            _membershipService = membershipService ?? throw new ArgumentNullException(nameof(membershipService));
            _participationService = participationService ?? throw new ArgumentNullException(nameof(participationService));
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

        [HttpGet("users-per-organization")]
        public async Task<ActionResult> GetUsersPerOrganization()
        {
            var organizations = await _organizationService.GetAsync(new Model.SearchObjects.OrganizationSearchObject());
            var memberships = await _membershipService.GetAsync(new Model.SearchObjects.MembershipSearchObject());
            var participations = await _participationService.GetAsync(new Model.SearchObjects.ParticipationSearchObject());
            var events = await _eventService.GetAsync(new Model.SearchObjects.EventSearchObject());

            var orgData = organizations.Items.Select(org => new
            {
                OrganizationName = org.Name,
                // Count members (users who have membership in this organization)
                MemberCount = memberships.Items.Count(m => m.OrganizationId == org.Id),
                // Count unique event participants (users who participated in events organized by this organization)
                EventParticipantCount = participations.Items
                    .Where(p => events.Items.Any(e => e.Id == p.EventId && e.OrganizationId == org.Id))
                    .Select(p => p.UserId)
                    .Distinct()
                    .Count(),
                // Total unique users (members + event participants)
                TotalUsers = memberships.Items
                    .Where(m => m.OrganizationId == org.Id)
                    .Select(m => m.UserId)
                    .Union(
                        participations.Items
                            .Where(p => events.Items.Any(e => e.Id == p.EventId && e.OrganizationId == org.Id))
                            .Select(p => p.UserId)
                    )
                    .Distinct()
                    .Count()
            })
            .OrderByDescending(x => x.TotalUsers)
            .ToList();

            return Ok(orgData);
        }
    }
}
