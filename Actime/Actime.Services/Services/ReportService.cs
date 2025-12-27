using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class ReportService : BaseCrudService<Model.Entities.Report, ReportSearchObject, Database.Report, ReportInsertRequest, ReportUpdateRequest>, IReportService
    {
        public ReportService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Report> ApplyFilter(IQueryable<Report> query, ReportSearchObject search)
        {
            if (!search.IncludeDeleted)
            {
                query = query.Where(x => !x.IsDeleted);
            }

            if (search.OrganizationId.HasValue)
            {
                query = query.Where(x => x.OrganizationId == search.OrganizationId.Value);
            }

            if (search.ReportTypeId.HasValue)
            {
                query = query.Where(x => x.ReportTypeId == search.ReportTypeId.Value);
            }

            if (search.CreatedFrom.HasValue)
            {
                query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);
            }

            if (search.CreatedTo.HasValue)
            {
                query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);
            }

            query = query.OrderByDescending(x => x.CreatedAt);

            return base.ApplyFilter(query, search);
        }

        protected override async Task<bool> OnDeleting(Report entity)
        {
            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.Now;

            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return false;
        }

        protected override Task OnCreating(Report entity, ReportInsertRequest request)
        {
            entity.CreatedAt = DateTime.Now;
            return Task.CompletedTask;
        }

        public async Task<List<Model.Entities.Report>> GetOrganizationReportsAsync(int organizationId)
        {
            var reports = await _context.Set<Report>()
                .Where(x => x.OrganizationId == organizationId && !x.IsDeleted)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Report>>(reports);
        }

        public async Task<List<Model.Entities.Report>> GetReportsByTypeAsync(int reportTypeId)
        {
            var reports = await _context.Set<Report>()
                .Where(x => x.ReportTypeId == reportTypeId && !x.IsDeleted)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Report>>(reports);
        }
    }
}