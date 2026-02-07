using Actime.Model.Constants;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class UserService : BaseService<Model.Entities.User, UserSearchObject, Database.User>, IUserService
    {
        private readonly ActimeContext _context;
        private readonly IMapper _mapper;

        public UserService(
            ActimeContext context,
            IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<Model.Entities.User> UpdateAsync(int userId, UserUpdateRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted);

            if (user == null)
                throw new Exception("User not found");

            if (request.FirstName != null)
                user.FirstName = request.FirstName;

            if (request.LastName != null)
                user.LastName = request.LastName;

            // Handle ProfileImageUrl - empty string => remove image
            if (request.ProfileImageUrl == "")
                user.ProfileImageUrl = null;
            else if (request.ProfileImageUrl != null)
                user.ProfileImageUrl = request.ProfileImageUrl;

            user.LastModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var dto = _mapper.Map<Model.Entities.User>(user);
            return dto;
        }

        public async Task SoftDeleteAsync(int userId, int deletedByUserId)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                throw new Exception("User not found");

            if (user.IsDeleted)
                throw new Exception("User is already deleted");

            user.IsDeleted = true;
            user.DeletedAt = DateTime.UtcNow;
            user.DeletedBy = deletedByUserId;

            var organization = await _context.Organizations
                .FirstOrDefaultAsync(o => o.UserId == userId && !o.IsDeleted);

            if (organization != null)
            {
                organization.IsDeleted = true;
                organization.DeletedAt = DateTime.UtcNow;
                organization.DeletedBy = deletedByUserId;
            }

            await _context.SaveChangesAsync();
        }

        public async Task<bool> ExistsAsync(int userId)
        {
            return await _context.Users
                .AnyAsync(u => u.Id == userId && !u.IsDeleted);
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
        {
            search ??= new UserSearchObject();

            if (!string.IsNullOrEmpty(search.Text))
            {
                query = query.Where(u => (u.FirstName != null && u.FirstName.ToLower().Contains(search.Text.ToLower())) ||
                                        (u.LastName != null && u.LastName.ToLower().Contains(search.Text.ToLower())));
            }

            if (!search.IncludeOrganizations)
            {
                query = query.Where(u => !_context.Organizations.Any(o => o.UserId == u.Id && !o.IsDeleted));
            }

            query = query.Where(u => !_context.UserRoles.Any(ur => ur.UserId == u.Id && ur.RoleId == (int)Role.Admin));

            return query;
        }
    }
}