using Actime.Model.Requests;
using Actime.Model.Responses;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Actime.Controllers
{
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
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

            if (string.IsNullOrEmpty(refreshToken))
                throw new Exception("Not authenticated");

            var response = await _authService.RefreshTokenAsync(refreshToken);
            SetRefreshTokenCookie(response.RefreshToken);
            return Ok(response);
        }

        /// <summary>
        /// Confirm email address
        /// </summary>
        /// <remarks>
        /// This is called when the user clicks the link in the email.
        /// The frontend needs to parse userId and token from the URL.
        /// </remarks>
        [HttpPost("confirm-email")]
        public async Task<ActionResult> ConfirmEmail([FromBody] ConfirmEmailRequest request)
        {
            await _authService.ConfirmEmailAsync(request);
            return Ok(new { message = "Email confirmed successfully. You can now log in." });
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
        /// Reset password with token
        /// </summary>
        /// <remarks>
        /// This is called when the user fills out the new password form.
        /// The token comes from the URL (email link).
        /// </remarks>
        [HttpPost("reset-password")]
        public async Task<ActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Password has been reset successfully. You can now log in with your new password." });
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