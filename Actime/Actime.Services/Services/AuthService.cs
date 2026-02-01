using Actime.Model.Requests;
using Actime.Model.Responses;
using Actime.Model.Settings;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System.ComponentModel.DataAnnotations;
using System.Net;

namespace Actime.Services.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<User> _userManager;
        private readonly ActimeContext _context;
        private readonly IJwtService _jwtService;
        private readonly IEmailService _emailService;
        private readonly IMapper _mapper;
        private readonly JwtSettings _jwtSettings;
        private readonly EmailSettings _emailSettings;

        public AuthService(
            UserManager<User> userManager,
            ActimeContext context,
            IJwtService jwtService,
            IEmailService emailService,
            IMapper mapper,
            IOptions<JwtSettings> jwtSettings,
            IOptions<EmailSettings> emailSettings)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _jwtService = jwtService ?? throw new ArgumentNullException(nameof(jwtService));
            _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _jwtSettings = jwtSettings.Value;
            _emailSettings = emailSettings.Value;
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
                throw new Exception("User with this email already exists");

            var nameParts = request.Username.Trim().Split(' ', 2);

            var user = new User
            {
                Email = request.Email,
                UserName = request.Email,
                FirstName = nameParts[0],
                LastName = nameParts.Length > 1 ? nameParts[1] : null,
                CreatedAt = DateTime.UtcNow,
                EmailConfirmed = false,
                DateOfBirth = request.DateOfBirth ?? DateTime.UtcNow
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                throw new ValidationException(string.Join(", ", errors));
            }

            var role = request.IsOrganization ? "Organization" : "User";
            await _userManager.AddToRoleAsync(user, role);

            await SendConfirmationEmailAsync(user);

            var response = await GenerateAuthResponseAsync(user);
            response.RequiresOrganizationSetup = request.IsOrganization;

            return response;
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null || user.IsDeleted)
                throw new Exception("Invalid email or password");

            var validPassword = await _userManager.CheckPasswordAsync(user, request.Password);
            if (!validPassword)
                throw new Exception("Invalid email or password");

            if (!user.EmailConfirmed)
                throw new Exception("Please confirm your email before logging in");

            return await GenerateAuthResponseAsync(user);
        }

        public async Task<string> GenerateEmailConfirmationTokenAsync(int userId)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null)
                throw new Exception("User not found");

            return await _userManager.GenerateEmailConfirmationTokenAsync(user);
        }

        public async Task ConfirmEmailAsync(ConfirmEmailRequest request)
        {
            var user = await _userManager.FindByIdAsync(request.UserId.ToString());
            if (user == null)
                throw new Exception("User not found");

            if (user.EmailConfirmed)
                throw new Exception("Email is already confirmed");

            // Decode token (frontend ga enkodira za URL)
            var decodedToken = WebUtility.UrlDecode(request.Token);

            var result = await _userManager.ConfirmEmailAsync(user, decodedToken);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                throw new ValidationException(string.Join(", ", errors));
            }

            var roles = await _userManager.GetRolesAsync(user);
            if (roles.Contains("Organization"))
            {
                var org = await _context.Organizations
                    .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsDeleted);

                if (org != null)
                    await _emailService.SendOrganizationWelcomeEmailAsync(user.Email!, user.FirstName ?? "User", org.Name);
                else
                    await _emailService.SendWelcomeEmailAsync(user.Email!, user.FirstName ?? "User");
            }
            else
            {
                await _emailService.SendWelcomeEmailAsync(user.Email!, user.FirstName ?? "User");
            }
        }

        public async Task ResendConfirmationEmailAsync(ResendConfirmationEmailRequest request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);

            if (user == null || user.IsDeleted)
                return;

            if (user.EmailConfirmed)
                throw new Exception("Email is already confirmed");

            await SendConfirmationEmailAsync(user);
        }

        public async Task ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);

            // Silent fail - ne otkrivamo postoji li email (security)
            if (user == null || user.IsDeleted || !user.EmailConfirmed)
                return;

            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var encodedToken = WebUtility.UrlEncode(token);

            var resetLink = $"{_emailSettings.FrontendBaseUrl}/reset-password?email={request.Email}&token={encodedToken}";

            await _emailService.SendPasswordResetAsync(user.Email!, user.FirstName ?? "User", resetLink);
        }

        public async Task ResetPasswordAsync(ResetPasswordRequest request)
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null || user.IsDeleted)
                throw new ValidationException("Invalid request");

            var decodedToken = WebUtility.UrlDecode(request.Token);

            var result = await _userManager.ResetPasswordAsync(user, decodedToken, request.NewPassword);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                throw new ValidationException(string.Join(", ", errors));
            }

            await _context.SaveChangesAsync();
        }

        public async Task ChangePasswordAsync(int userId, ChangePasswordRequest request)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null || user.IsDeleted)
                throw new Exception("User not found");

            var result = await _userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
            if (!result.Succeeded)
            {
                var errors = result.Errors.Select(e => e.Description);
                throw new ValidationException(string.Join(", ", errors));
            }
        }

        public async Task<AuthResponse> CompleteOrganizationSetupAsync(int userId, CompleteOrganizationRequest request)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null || user.IsDeleted)
                throw new Exception("User not found");

            var hasOrganization = await _context.Organizations
                .AnyAsync(o => o.UserId == userId && !o.IsDeleted);

            if (hasOrganization)
                throw new Exception("User already has an organization");

            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists)
                throw new ValidationException("Invalid category");

            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var address = await _context.Addresses.FindAsync(request.AddressId);
                if (address == null)
                    throw new Exception("Address not found");


                var organization = new Organization
                {
                    Name = user.UserName!,
                    Email = user.Email!,
                    Description = request.Description,
                    PhoneNumber = request.PhoneNumber,
                    CategoryId = request.CategoryId,
                    AddressId = address.Id,
                    UserId = userId,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Organizations.Add(organization);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                if (user.EmailConfirmed)
                {
                    await _emailService.SendOrganizationWelcomeEmailAsync(
                        user.Email!,
                        user.FirstName ?? "User",
                        organization.Name);
                }

                return await GenerateAuthResponseAsync(user);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        #region Helpers

        private async Task SendConfirmationEmailAsync(User user)
        {
            var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
            var encodedToken = WebUtility.UrlEncode(token);

            var confirmationLink = $"{_emailSettings.FrontendBaseUrl}/confirm-email?userId={user.Id}&token={encodedToken}";

            await _emailService.SendEmailConfirmationAsync(
                user.Email!,
                user.FirstName ?? "User",
                confirmationLink);
        }

        private async Task<AuthResponse> GenerateAuthResponseAsync(User user)
        {
            var roles = await _userManager.GetRolesAsync(user);
            var accessToken = _jwtService.GenerateAccessToken(user, roles);
            var refreshToken = _jwtService.GenerateRefreshToken();

            var refreshTokenEntity = new RefreshToken
            {
                Token = refreshToken,
                UserId = user.Id,
                ExpiresAt = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays),
            };
            _context.RefreshTokens.Add(refreshTokenEntity);
            await _context.SaveChangesAsync();

            Model.Entities.Organization? organizationDto = null;
            if (roles.Contains("Organization"))
            {
                var organization = await _context.Organizations
                    .Include(o => o.Category)
                    .Include(o => o.Address)
                    .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsDeleted);

                if (organization != null)
                    organizationDto = _mapper.Map<Model.Entities.Organization>(organization);
            }

            return new AuthResponse
            {
                UserId = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                ExpiresAt = DateTime.UtcNow.AddMinutes(_jwtSettings.AccessTokenExpirationMinutes),
                Roles = roles.ToList(),
                RequiresOrganizationSetup = roles.Contains("Organization") && organizationDto == null,
                Organization = organizationDto
            };
        }

        public async Task<AuthResponse> RefreshTokenAsync(string refreshToken)
        {
            var token = await _context.RefreshTokens
                .Include(r => r.User)
                .FirstOrDefaultAsync(r => r.Token == refreshToken);

            if (token == null)
                throw new Exception("Invalid refresh token");

            if (!token.IsActive)
                throw new Exception("Refresh token expired or revoked");

            if (token.User.IsDeleted)
                throw new Exception("User account is deleted");

            token.RevokedAt = DateTime.UtcNow;
            token.ReasonRevoked = "Replaced by new token";

            var response = await GenerateAuthResponseAsync(token.User);

            token.ReplacedByToken = response.RefreshToken;
            await _context.SaveChangesAsync();

            return response;
        }

        public async Task RevokeTokenAsync(string refreshToken)
        {
            var token = await _context.RefreshTokens
                .FirstOrDefaultAsync(r => r.Token == refreshToken);

            if (token == null)
                return;

            if (token.IsActive)
            {
                token.RevokedAt = DateTime.UtcNow;
                token.ReasonRevoked = "Revoked by user";
                await _context.SaveChangesAsync();
            }
        }

        public async Task<AuthResponse> GetCurrentUserAsync(int userId)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            
            if (user == null || user.IsDeleted)
                throw new Exception("User not found");

            var roles = await _userManager.GetRolesAsync(user);

            Model.Entities.Organization? organizationDto = null;
            
            if (roles.Contains("Organization"))
            {
                var organization = await _context.Organizations
                    .Include(o => o.Category)
                    .Include(o => o.Address)
                    .FirstOrDefaultAsync(o => o.UserId == user.Id && !o.IsDeleted);

                if (organization != null)
                    organizationDto = _mapper.Map<Model.Entities.Organization>(organization);
            }

            return new AuthResponse
            {
                UserId = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                // Client already has valid Bearer token
                AccessToken = string.Empty,
                RefreshToken = string.Empty,
                ExpiresAt = DateTime.MinValue,
                Roles = roles.ToList(),
                RequiresOrganizationSetup = roles.Contains("Organization") && organizationDto == null,
                Organization = organizationDto
            };
        }

        #endregion
    }
}