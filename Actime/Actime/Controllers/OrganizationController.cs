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
    public class OrganizationController : BaseController<Organization, TextSearchObject>
    {
        private readonly IOrganizationService _organizationService;

        public OrganizationController(IOrganizationService organizationService) : base(organizationService)
        {
            _organizationService = organizationService ?? throw new ArgumentNullException(nameof(organizationService));
        }

        [AllowAnonymous]
        public override Task<PagedResult<Organization>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [HttpPut("my")]
        [Authorize(Roles = "Organization")]
        public async Task<ActionResult<Organization>> UpdateMyOrganization([FromBody] OrganizationUpdateRequest request)
        {
            var userId = GetCurrentUserId();
            var myOrg = await _organizationService.GetByIdAsync(userId);

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

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                throw new Exception("Invalid token");

            return userId;
        }
    }
}