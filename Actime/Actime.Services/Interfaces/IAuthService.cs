using Actime.Model.Requests;
using Actime.Model.Responses;

namespace Actime.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<AuthResponse> CompleteOrganizationSetupAsync(int userId, CompleteOrganizationRequest request);
        Task<AuthResponse> RefreshTokenAsync(string refreshToken);
        Task RevokeTokenAsync(string token);

        Task<string> GenerateEmailConfirmationTokenAsync(int userId);
        Task ConfirmEmailAsync(ConfirmEmailRequest request);
        Task ResendConfirmationEmailAsync(ResendConfirmationEmailRequest request);

        Task ForgotPasswordAsync(ForgotPasswordRequest request);
        Task ResetPasswordAsync(ResetPasswordRequest request);
        Task ChangePasswordAsync(int userId, ChangePasswordRequest request);

        Task<AuthResponse> GetCurrentUserAsync(int userId);
    }
}
