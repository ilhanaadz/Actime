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
    [Authorize]
    public class UserController : BaseController<User, UserSearchObject>
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService) : base(userService)
        {
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
        }

        [HttpPut("profile")]
        public async Task<ActionResult<User>> UpdateProfile([FromBody] UserUpdateRequest request)
        {
            var userId = GetCurrentUserId();
            var user = await _userService.UpdateAsync(userId, request);
            return Ok(user);
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<User>> Update(int id, [FromBody] UserUpdateRequest request)
        {
            var user = await _userService.UpdateAsync(id, request);
            return Ok(user);
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult> Delete(int id)
        {
            var adminUserId = GetCurrentUserId();
            await _userService.SoftDeleteAsync(id, adminUserId);
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