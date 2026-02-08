using Actime.Model.Requests;
using Actime.Model.Responses;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Security.Claims;

namespace Actime.Controllers
{
    [ApiController]
    [Route("")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IWebHostEnvironment _env;

        public AuthController(IAuthService authService, IWebHostEnvironment env)
        {
            _authService = authService;
            _env = env;
        }

        [HttpPost("login")]
        public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
        {
            var response = await _authService.LoginAsync(request);
            SetRefreshTokenCookie(response.RefreshToken);
            return Ok(response);
        }

        [HttpPost("register")]
        public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
        {
            var response = await _authService.RegisterAsync(request);
            SetRefreshTokenCookie(response.RefreshToken);
            return CreatedAtAction(nameof(Login), response);
        }

        [HttpPost("logout")]
        public async Task<ActionResult> Logout()
        {
            var refreshToken = Request.Cookies["refreshToken"];

            if (!string.IsNullOrEmpty(refreshToken))
                await _authService.RevokeTokenAsync(refreshToken);

            DeleteRefreshTokenCookie();
            return Ok(new { message = "Logged out successfully" });
        }

        [HttpPost("complete-organization")]
        [Authorize(Roles = "Organization")]
        public async Task<ActionResult<AuthResponse>> CompleteOrganization([FromBody] CompleteOrganizationRequest request)
        {
            var userId = GetCurrentUserId();
            var response = await _authService.CompleteOrganizationSetupAsync(userId, request);
            return Ok(response);
        }

        [HttpPost("refresh-token")]
        public async Task<ActionResult<AuthResponse>> RefreshToken()
        {
            var refreshToken = Request.Cookies["refreshToken"];

            if (string.IsNullOrEmpty(refreshToken))
                throw new Exception("Refresh token not found");

            var response = await _authService.RefreshTokenAsync(refreshToken);
            SetRefreshTokenCookie(response.RefreshToken);
            return Ok(response);
        }

        [HttpGet("me")]
        [Authorize]
        public async Task<ActionResult<AuthResponse>> GetCurrentUser()
        {
            var refreshToken = Request.Cookies["refreshToken"];

            // If refresh token exists (web browser), refresh it and return full auth response
            if (!string.IsNullOrEmpty(refreshToken))
            {
                var responseData = await _authService.RefreshTokenAsync(refreshToken);
                SetRefreshTokenCookie(responseData.RefreshToken);
                return Ok(responseData);
            }

            // If no refresh token (mobile app with Bearer token), return user data without tokens
            var userId = GetCurrentUserId();
            var response = await _authService.GetCurrentUserAsync(userId);
            return Ok(response);
        }

        /// <summary>
        /// Confirm email address (API - JSON)
        /// </summary>
        [HttpPost("confirm-email")]
        public async Task<ActionResult> ConfirmEmail([FromBody] ConfirmEmailRequest request)
        {
            await _authService.ConfirmEmailAsync(request);
            return Ok(new { message = "Email confirmed successfully. You can now log in." });
        }

        /// <summary>
        /// Confirm email address (Browser - HTML)
        /// </summary>
        /// <remarks>
        /// This is the link the user clicks from the confirmation email.
        /// </remarks>
        [HttpGet("confirm-email")]
        public async Task<IActionResult> ConfirmEmailFromLink([FromQuery] int userId, [FromQuery] string token)
        {
            try
            {
                // Re-encode: ASP.NET auto-decodes query params, but ConfirmEmailAsync expects URL-encoded token
                await _authService.ConfirmEmailAsync(new ConfirmEmailRequest
                {
                    UserId = userId,
                    Token = WebUtility.UrlEncode(token)
                });

                return PhysicalFile(
                    Path.Combine(_env.WebRootPath, "email-pages", "confirm-success.html"),
                    "text/html");
            }
            catch
            {
                return PhysicalFile(
                    Path.Combine(_env.WebRootPath, "email-pages", "confirm-error.html"),
                    "text/html");
            }
        }

        /// <summary>
        /// Resend confirmation email
        /// </summary>
        [HttpPost("resend-confirmation-email")]
        public async Task<ActionResult> ResendConfirmationEmail([FromBody] ResendConfirmationEmailRequest request)
        {
            await _authService.ResendConfirmationEmailAsync(request);
            return Ok(new { message = "If your email exists and is not confirmed, you will receive a confirmation link." });
        }

        /// <summary>
        /// Request password reset (forgot password)
        /// </summary>
        /// <remarks>
        /// Sends an email with a reset link.
        /// Always returns success (security - we do not disclose whether the email exists).
        /// </remarks>
        [HttpPost("forgot-password")]
        public async Task<ActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            await _authService.ForgotPasswordAsync(request);
            return Ok(new { message = "If your email exists, you will receive a password reset link." });
        }

        /// <summary>
        /// Reset password with token (API - JSON)
        /// </summary>
        [HttpPost("reset-password")]
        public async Task<ActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Password has been reset successfully. You can now log in with your new password." });
        }

        /// <summary>
        /// Reset password form (Browser - HTML)
        /// </summary>
        /// <remarks>
        /// This is the link the user clicks from the password reset email.
        /// The static HTML reads email/token from URL query params via JavaScript.
        /// </remarks>
        [HttpGet("reset-password")]
        public IActionResult ResetPasswordForm()
        {
            return PhysicalFile(
                Path.Combine(_env.WebRootPath, "email-pages", "reset-password.html"),
                "text/html");
        }

        /// <summary>
        /// Change password (for logged-in users)
        /// </summary>
        [HttpPost("change-password")]
        [Authorize]
        public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var userId = GetCurrentUserId();
            await _authService.ChangePasswordAsync(userId, request);
            return Ok(new { message = "Password changed successfully." });
        }

        /// <summary>
        /// Delete my account (for logged-in users)
        /// </summary>
        /// <remarks>
        /// Allows users to delete their own account without admin privileges.
        /// Use hardDelete=true for incomplete registrations (completely removes from DB).
        /// Use hardDelete=false (default) for regular profiles (soft delete).
        /// </remarks>
        [HttpDelete("delete-my-account")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<ActionResult> DeleteMyAccount([FromQuery] bool hardDelete = false)
        {
            var userId = GetCurrentUserId();
            await _authService.DeleteMyAccountAsync(userId, hardDelete);

            var refreshToken = Request.Cookies["refreshToken"];
            if (!string.IsNullOrEmpty(refreshToken))
                await _authService.RevokeTokenAsync(refreshToken);

            DeleteRefreshTokenCookie();
            return NoContent();
        }

        private void SetRefreshTokenCookie(string token)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTime.UtcNow.AddDays(7)
            };
            Response.Cookies.Append("refreshToken", token, cookieOptions);
        }

        private void DeleteRefreshTokenCookie()
        {
            Response.Cookies.Delete("refreshToken", new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict
            });
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