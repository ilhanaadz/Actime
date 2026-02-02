using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Actime.Controllers
{
    public class MembershipController : BaseCrudController<Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
        private readonly IMembershipService _membershipService;

        public MembershipController(IMembershipService membershipService) : base(membershipService)
        {
            _membershipService = membershipService;
        }

        /// <summary>
        /// Get memberships for the currently authenticated user
        /// Returns active memberships (status = 2) with organization details
        /// </summary>
        [HttpGet("my")]
        public async Task<ActionResult<PagedResult<Membership>>> GetMyMemberships(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized("User ID not found in token");
            }

            var search = new MembershipSearchObject
            {
                UserId = userId,
                MembershipStatusId = 2, // Active/Approved status
                IncludeOrganization = true,
                Page = page,
                PageSize = pageSize,
                IncludeTotalCount = true
            };

            var result = await _service.GetAsync(search);
            return Ok(result);
        }

        /// <summary>
        /// Cancel membership or pending application by organization ID for the current user
        /// </summary>
        [HttpDelete("organization/{organizationId}")]
        public async Task<ActionResult> CancelMembershipByOrganization(int organizationId)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
            {
                return Unauthorized("User ID not found in token");
            }

            var result = await _membershipService.CancelMembershipByOrganizationAsync(userId, organizationId);

            if (!result)
            {
                return NotFound("Membership or pending application not found for this organization");
            }

            return NoContent();
        }
    }
}
