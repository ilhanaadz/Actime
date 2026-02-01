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

        public override async Task<Model.Entities.Organization?> GetByIdAsync(int id)
        {
            var entity = await _context.Organizations
                .Include(o => o.User)
                .Include(o => o.Category)
                .Include(o => o.Address)
                    .ThenInclude(a => a.City)
                        .ThenInclude(c => c.Country)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (entity == null)
                return null;

            var dto = _mapper.Map<Model.Entities.Organization>(entity);
            PopulateOrganizationFields(dto, entity);

            return dto;
        }

        public override async Task<Model.Common.PagedResult<Model.Entities.Organization>> GetAsync(TextSearchObject search)
        {
            search ??= new TextSearchObject();

            var query = _context.Set<Organization>().AsQueryable();
            query = ApplyFilter(query, search);
            query = ApplySorting(query, search);

            int? totalCount = search.IncludeTotalCount ? await query.CountAsync() : null;

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    int skip = (search.Page.Value - 1) * search.PageSize.Value;
                    query = query.Skip(skip).Take(search.PageSize.Value);
                }
                else if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var entities = await query.ToListAsync();
            var result = new List<Model.Entities.Organization>();

            foreach (var entity in entities)
            {
                var dto = _mapper.Map<Model.Entities.Organization>(entity);
                PopulateOrganizationFields(dto, entity);
                result.Add(dto);
            }

            return new Model.Common.PagedResult<Model.Entities.Organization>
            {
                Items = result,
                TotalCount = totalCount ?? result.Count
            };
        }

        protected override IQueryable<Organization> ApplyFilter(IQueryable<Organization> query, TextSearchObject search)
        {
            query = query
                .Include(o => o.User)
                .Include(o => o.Category)
                .Include(o => o.Address)
                    .ThenInclude(a => a.City)
                        .ThenInclude(c => c.Country);

            if (!string.IsNullOrWhiteSpace(search?.Text))
            {
                query = query.Where(o => o.Name.Contains(search.Text) ||
                                        (o.Description != null && o.Description.Contains(search.Text)));
            }

            return query;
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
            PopulateOrganizationFields(dto, organization);
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

        public async Task<Model.Entities.Organization?> GetByUserIdAsync(int userId)
        {
            var organization = await _context.Organizations
                .Include(o => o.User)
                .Include(o => o.Category)
                .Include(o => o.Address)
                    .ThenInclude(a => a.City)
                        .ThenInclude(c => c.Country)
                .FirstOrDefaultAsync(o => o.UserId == userId && !o.IsDeleted);

            if (organization == null)
                return null;

            var dto = _mapper.Map<Model.Entities.Organization>(organization);
            PopulateOrganizationFields(dto, organization);

            return dto;
        }

        private void PopulateOrganizationFields(Model.Entities.Organization dto, Organization entity)
        {
            if (entity.Category != null)
            {
                dto.CategoryName = entity.Category.Name;
            }

            if (entity.Address != null)
            {
                var addressParts = new List<string> { entity.Address.Street };

                if (entity.Address.City != null)
                {
                    addressParts.Add(entity.Address.City.Name);

                    if (entity.Address.City.Country != null)
                    {
                        addressParts.Add(entity.Address.City.Country.Name);
                    }
                }

                dto.Address = string.Join(", ", addressParts);
            }
        }
    }
}
