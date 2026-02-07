using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Actime.Controllers
{
    public class OrganizationController : BaseController<Organization, OrganizationSearchObject>
    {
        private readonly IOrganizationService _organizationService;

        public OrganizationController(IOrganizationService organizationService) : base(organizationService)
        {
            _organizationService = organizationService ?? throw new ArgumentNullException(nameof(organizationService));
        }

        [AllowAnonymous]
        public override Task<Organization?> GetById(int id)
        {
            // Admin users can see all organization details, including unconfirmed
            if (User.IsInRole("Admin"))
            {
                return _organizationService.GetByIdAsync(id);
            }

            var currentUserId = GetCurrentUserIdOrNull();
            return _organizationService.GetByIdForUserAsync(id, currentUserId);
        }

        [AllowAnonymous]
        public override Task<PagedResult<Organization>> Get([FromQuery] OrganizationSearchObject? search = null)
        {
            // Admin users can see all organizations, including unconfirmed
            if (User.IsInRole("Admin"))
            {
                search ??= new OrganizationSearchObject();
                search.IncludeUnconfirmed = true;
            }

            return base.Get(search);
        }

        [HttpPut("my")]
        [Authorize(Roles = "Organization")]
        public async Task<ActionResult<Organization>> UpdateMyOrganization([FromBody] OrganizationUpdateRequest request)
        {
            var userId = GetCurrentUserId();
            var myOrg = await _organizationService.GetByUserIdAsync(userId);

            if (myOrg == null)
                throw new Exception("You don't have an organization");

            var organization = await _organizationService.UpdateAsync(myOrg.Id, userId, request);
            return Ok(organization);
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<Organization>> Update(int id, [FromBody] OrganizationUpdateRequest request)
        {
            var organization = await _organizationService.GetByIdAsync(id);
            if (organization == null)
                throw new Exception("Organization not found");

            var result = await _organizationService.UpdateAsync(id, organization.UserId, request);
            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> Delete(int id)
        {
            var organization = await _organizationService.GetByIdAsync(id);
            if (organization == null)
                throw new Exception("Organization not found");

            await _organizationService.SoftDeleteAsync(id, organization.UserId);
            return NoContent();
        }

        [HttpDelete("my")]
        [Authorize(Roles = "Organization")]
        public async Task<ActionResult> DeleteMyOrganization()
        {
            var userId = GetCurrentUserId();
            var myOrg = await _organizationService.GetByIdAsync(userId);

            if (myOrg == null)
                throw new Exception("You don't have an organization");

            await _organizationService.SoftDeleteAsync(myOrg.Id, userId);
            return NoContent();
        }

        [HttpGet("{id:int}/participations")]
        [AllowAnonymous]
        public async Task<ActionResult<List<EventParticipation>>> GetOrganizationParticipations(int id)
        {
            var result = await _organizationService.GetOrganizationParticipationsAsync(id);
            return Ok(result);
        }

        [HttpGet("{id:int}/participations/by-month")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ParticipationByMonth>>> GetOrganizationParticipationsByMonth(int id)
        {
            var result = await _organizationService.GetOrganizationParticipationsByMonthAsync(id);
            return Ok(result);
        }

        [HttpGet("{id:int}/participations/by-year")]
        [AllowAnonymous]
        public async Task<ActionResult<List<ParticipationByYear>>> GetOrganizationParticipationsByYear(int id)
        {
            var result = await _organizationService.GetOrganizationParticipationsByYearAsync(id);
            return Ok(result);
        }

        [HttpGet("{id:int}/participants/month/{month:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<User>>> GetParticipantsByMonth(int id, int month)
        {
            var result = await _organizationService.GetParticipantsByMonthAsync(id, month);
            return Ok(result);
        }

        [HttpGet("{id:int}/participants/year/{year:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<User>>> GetParticipantsByYear(int id, int year)
        {
            var result = await _organizationService.GetParticipantsByYearAsync(id, year);
            return Ok(result);
        }

        [HttpGet("{id:int}/enrollments/by-month")]
        [AllowAnonymous]
        public async Task<ActionResult<List<EnrollmentByMonth>>> GetOrganizationEnrollmentsByMonth(int id)
        {
            var result = await _organizationService.GetOrganizationEnrollmentsByMonthAsync(id);
            return Ok(result);
        }

        [HttpGet("{id:int}/enrollments/by-year")]
        [AllowAnonymous]
        public async Task<ActionResult<List<EnrollmentByYear>>> GetOrganizationEnrollmentsByYear(int id)
        {
            var result = await _organizationService.GetOrganizationEnrollmentsByYearAsync(id);
            return Ok(result);
        }

        [HttpGet("{id:int}/members/month/{month:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<User>>> GetMembersByMonth(int id, int month)
        {
            var result = await _organizationService.GetMembersByMonthAsync(id, month);
            return Ok(result);
        }

        [HttpGet("{id:int}/members/year/{year:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<User>>> GetMembersByYear(int id, int year)
        {
            var result = await _organizationService.GetMembersByYearAsync(id, year);
            return Ok(result);
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                throw new Exception("Invalid token");

            return userId;
        }

        private int? GetCurrentUserIdOrNull()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                return null;

            return userId;
        }
    }
}