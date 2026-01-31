using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace Actime.Services.Services
{
    public class OrganizationService : BaseService<Model.Entities.Organization, TextSearchObject, Organization>, IOrganizationService
    {
        public OrganizationService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<Model.Entities.Organization> UpdateAsync(int organizationId, int userId, OrganizationUpdateRequest request)
        {
            var organization = await _context.Organizations
                .Include(o => o.User)
                .Include(o => o.Category)
                .Include(o => o.Address)
                .FirstOrDefaultAsync(o => o.Id == organizationId && !o.IsDeleted);

            if (organization == null)
                throw new Exception("Organization not found");

            if (organization.UserId != userId)
                throw new Exception("You are not authorized to update this organization");

            if (request.Name != null)
                organization.Name = request.Name;

            if (request.Email != null)
                organization.Email = request.Email;

            if (request.Description != null)
                organization.Description = request.Description;

            if (request.LogoUrl != null)
                organization.LogoUrl = request.LogoUrl;

            if (request.PhoneNumber != null)
                organization.PhoneNumber = request.PhoneNumber;

            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId.Value);
                if (!categoryExists)
                    throw new ValidationException("Invalid category");

                organization.CategoryId = request.CategoryId.Value;
            }

            organization.LastModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            await _context.Entry(organization).Reference(o => o.Category).LoadAsync();

            var dto = _mapper.Map<Model.Entities.Organization>(organization);
            dto.Name = $"{organization.User.FirstName} {organization.User.LastName}".Trim();
            return dto;
        }

        public async Task SoftDeleteAsync(int organizationId, int deletedByUserId)
        {
            var organization = await _context.Organizations.FindAsync(organizationId);

            if (organization == null)
                throw new Exception("Organization not found");

            if (organization.IsDeleted)
                throw new Exception("Organization is already deleted");

            if (organization.UserId != deletedByUserId)
                throw new Exception("You are not authorized to delete this organization");

            organization.IsDeleted = true;
            organization.DeletedAt = DateTime.UtcNow;
            organization.DeletedBy = deletedByUserId;

            await _context.SaveChangesAsync();
        }

        public async Task<bool> UserOwnsOrganizationAsync(int userId, int organizationId)
        {
            return await _context.Organizations
                .AnyAsync(o => o.Id == organizationId && o.UserId == userId && !o.IsDeleted);
        }
    }
}
