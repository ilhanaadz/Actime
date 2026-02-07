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
                .Include(o => o.Memberships)
                .Include(o => o.Events)
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
                        .ThenInclude(c => c.Country)
                .Include(o => o.Memberships)
                .Include(o => o.Events);

            query = query.Where(o => o.User.EmailConfirmed);

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

            if (request.PhoneNumber != null)
                organization.PhoneNumber = request.PhoneNumber;

            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId.Value);
                if (!categoryExists)
                    throw new ValidationException("Invalid category");

                organization.CategoryId = request.CategoryId.Value;
            }

            if (request.AddressId.HasValue)
            {
                var addressExists = await _context.Addresses.AnyAsync(a => a.Id == request.AddressId.Value);
                if (!addressExists)
                    throw new ValidationException("Invalid address");

                organization.AddressId = request.AddressId.Value;
            }

            // Handle LogoUrl - empty string => remove logo
            if (request.LogoUrl == "")
                organization.LogoUrl = null;
            else if (request.LogoUrl != null)
                organization.LogoUrl = request.LogoUrl;

            organization.LastModifiedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            await _context.Entry(organization).Reference(o => o.Category).LoadAsync();
            await _context.Entry(organization).Reference(o => o.Address).LoadAsync();
            if (organization.Address != null)
            {
                await _context.Entry(organization.Address).Reference(a => a.City).LoadAsync();
                if (organization.Address.City != null)
                {
                    await _context.Entry(organization.Address.City).Reference(c => c.Country).LoadAsync();
                }
            }

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
                .Include(o => o.Memberships)
                .Include(o => o.Events)
                .FirstOrDefaultAsync(o => o.UserId == userId && !o.IsDeleted);

            if (organization == null)
                return null;

            var dto = _mapper.Map<Model.Entities.Organization>(organization);
            PopulateOrganizationFields(dto, organization);

            return dto;
        }

        public async Task<Model.Entities.Organization?> GetByIdForUserAsync(int organizationId, int? currentUserId)
        {
            var entity = await _context.Organizations
                .Include(o => o.User)
                .Include(o => o.Category)
                .Include(o => o.Address)
                    .ThenInclude(a => a.City)
                        .ThenInclude(c => c.Country)
                .Include(o => o.Memberships)
                .Include(o => o.Events)
                .FirstOrDefaultAsync(o => o.Id == organizationId && o.User.EmailConfirmed);

            if (entity == null)
                return null;

            var dto = _mapper.Map<Model.Entities.Organization>(entity);
            PopulateOrganizationFields(dto, entity, currentUserId);

            return dto;
        }

        private void PopulateOrganizationFields(Model.Entities.Organization dto, Organization entity, int? currentUserId = null)
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

            // Count only active memberships (MembershipStatusId = 2 is active)
            dto.MembersCount = entity.Memberships?.Count(m => m.MembershipStatusId == 2) ?? 0;

            // Count events (excluding deleted events)
            dto.EventsCount = entity.Events?.Count(e => !e.IsDeleted) ?? 0;

            // Check if current user is an active member and get their membership status
            if (currentUserId.HasValue && entity.Memberships != null)
            {
                var userMembership = entity.Memberships
                    .FirstOrDefault(m => m.UserId == currentUserId.Value);

                if (userMembership != null)
                {
                    dto.MembershipStatusId = userMembership.MembershipStatusId;
                    dto.IsMember = userMembership.MembershipStatusId == 2; // 2 = active membership
                }
                else
                {
                    dto.MembershipStatusId = null;
                    dto.IsMember = false;
                }
            }
            else
            {
                dto.MembershipStatusId = null;
                dto.IsMember = false;
            }
        }

        public async Task<List<Model.Entities.EventParticipation>> GetOrganizationParticipationsAsync(int organizationId)
        {
            var events = await _context.Events
                .Where(e => e.OrganizationId == organizationId && !e.IsDeleted)
                .Include(e => e.Participations.Where(p => !p.IsDeleted))
                .OrderByDescending(e => e.Start)
                .ToListAsync();

            var participations = events.Select(e => new Model.Entities.EventParticipation
            {
                EventId = e.Id,
                EventName = e.Title,
                ParticipantsCount = e.Participations?.Count ?? 0
            }).ToList();

            return participations;
        }

        public async Task<List<Model.Entities.ParticipationByMonth>> GetOrganizationParticipationsByMonthAsync(int organizationId)
        {
            var participationsQuery = _context.Participations
                .Include(p => p.Event)
                .Where(p => p.Event.OrganizationId == organizationId && !p.IsDeleted && !p.Event.IsDeleted);

            // Group by month only in database
            var grouped = await participationsQuery
                .GroupBy(p => p.Event.Start.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    ParticipantsCount = g.Select(p => p.UserId).Distinct().Count()
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            var items = grouped.Select(g => new Model.Entities.ParticipationByMonth
            {
                Year = 0, // Not used when grouping by month only
                Month = g.Month,
                MonthName = GetMonth(g.Month),
                ParticipantsCount = g.ParticipantsCount
            }).ToList();

            return items;
        }

        private string GetMonth(int month)
        {
            return month switch
            {
                1 => "January",
                2 => "February",
                3 => "March",
                4 => "April",
                5 => "May",
                6 => "June",
                7 => "July",
                8 => "August",
                9 => "September",
                10 => "October",
                11 => "November",
                12 => "December",
                _ => "Unknown"
            };
        }

        public async Task<List<Model.Entities.ParticipationByYear>> GetOrganizationParticipationsByYearAsync(int organizationId)
        {
            var grouped = await _context.Participations
                .Include(p => p.Event)
                .Where(p => p.Event.OrganizationId == organizationId && !p.IsDeleted && !p.Event.IsDeleted)
                .GroupBy(p => p.Event.Start.Year)
                .Select(g => new Model.Entities.ParticipationByYear
                {
                    Year = g.Key,
                    ParticipantsCount = g.Select(p => p.UserId).Distinct().Count()
                })
                .OrderByDescending(x => x.Year)
                .ToListAsync();

            return grouped;
        }

        public async Task<List<Model.Entities.User>> GetParticipantsByMonthAsync(int organizationId, int month)
        {
            var users = await _context.Participations
                .Include(p => p.Event)
                .Include(p => p.User)
                .Where(p => p.Event.OrganizationId == organizationId
                    && p.Event.Start.Month == month
                    && !p.IsDeleted
                    && !p.Event.IsDeleted
                    && !p.User.IsDeleted)
                .Select(p => p.User)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.User>>(users);
        }

        public async Task<List<Model.Entities.User>> GetParticipantsByYearAsync(int organizationId, int year)
        {
            var users = await _context.Participations
                .Include(p => p.Event)
                .Include(p => p.User)
                .Where(p => p.Event.OrganizationId == organizationId
                    && p.Event.Start.Year == year
                    && !p.IsDeleted
                    && !p.Event.IsDeleted
                    && !p.User.IsDeleted)
                .Select(p => p.User)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.User>>(users);
        }

        public async Task<List<Model.Entities.EnrollmentByMonth>> GetOrganizationEnrollmentsByMonthAsync(int organizationId)
        {
            var membershipsQuery = _context.Memberships
                .Where(m => m.OrganizationId == organizationId
                    && m.MembershipStatusId == 2 // Active members only
                    && !m.IsDeleted);

            var grouped = await membershipsQuery
                .GroupBy(m => m.StartDate!.Month)
                .Select(g => new
                {
                    Month = g.Key,
                    MembersCount = g.Select(m => m.UserId).Distinct().Count()
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            var items = grouped.Select(g => new Model.Entities.EnrollmentByMonth
            {
                Year = 0, // Not used when grouping by month only
                Month = g.Month,
                MonthName = GetMonth(g.Month),
                MembersCount = g.MembersCount
            }).ToList();

            return items;
        }

        public async Task<List<Model.Entities.EnrollmentByYear>> GetOrganizationEnrollmentsByYearAsync(int organizationId)
        {
            var grouped = await _context.Memberships
                .Where(m => m.OrganizationId == organizationId
                    && m.MembershipStatusId == 2 // Active members only
                    && !m.IsDeleted)
                .GroupBy(m => m.StartDate!.Year)
                .Select(g => new Model.Entities.EnrollmentByYear
                {
                    Year = g.Key,
                    MembersCount = g.Select(m => m.UserId).Distinct().Count()
                })
                .OrderByDescending(x => x.Year)
                .ToListAsync();

            return grouped;
        }

        public async Task<List<Model.Entities.User>> GetMembersByMonthAsync(int organizationId, int month)
        {
            var users = await _context.Memberships
                .Include(m => m.User)
                .Where(m => m.OrganizationId == organizationId
                    && m.MembershipStatusId == 2 // Active members only
                    && m.StartDate.Month == month
                    && !m.IsDeleted
                    && !m.User.IsDeleted)
                .Select(m => m.User)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.User>>(users);
        }

        public async Task<List<Model.Entities.User>> GetMembersByYearAsync(int organizationId, int year)
        {
            var users = await _context.Memberships
                .Include(m => m.User)
                .Where(m => m.OrganizationId == organizationId
                    && m.MembershipStatusId == 2 // Active members only
                    && m.StartDate.Year == year
                    && !m.IsDeleted
                    && !m.User.IsDeleted)
                .Select(m => m.User)
                .Distinct()
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.User>>(users);
        }
    }
}
