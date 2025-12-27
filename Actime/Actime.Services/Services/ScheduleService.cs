using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class ScheduleService : BaseCrudService<Model.Entities.Schedule, ScheduleSearchObject, Database.Schedule, ScheduleInsertRequest, ScheduleUpdateRequest>, IScheduleService
    {
        public ScheduleService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Schedule> ApplyFilter(IQueryable<Schedule> query, ScheduleSearchObject search)
        {
            if (search.OrganizationId.HasValue)
            {
                query = query.Where(x => x.OrganizationId == search.OrganizationId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.DayOfWeek))
            {
                query = query.Where(x => x.DayOfWeek == search.DayOfWeek);
            }

            if (search.ActivityTypeId.HasValue)
            {
                query = query.Where(x => x.ActivityTypeId == search.ActivityTypeId.Value);
            }

            if (search.LocationId.HasValue)
            {
                query = query.Where(x => x.LocationId == search.LocationId.Value);
            }

            if (search.StartTimeFrom.HasValue)
            {
                query = query.Where(x => x.StartTime >= search.StartTimeFrom.Value);
            }

            if (search.StartTimeTo.HasValue)
            {
                query = query.Where(x => x.StartTime <= search.StartTimeTo.Value);
            }

            query = query.OrderBy(x => x.DayOfWeek).ThenBy(x => x.StartTime);

            return base.ApplyFilter(query, search);
        }

        protected override Task OnCreating(Schedule entity, ScheduleInsertRequest request)
        {
            var validDays = new[] { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
            if (!validDays.Contains(entity.DayOfWeek))
            {
                throw new ArgumentException("Day of the week is invalid.");
            }

            if (entity.StartTime.HasValue && entity.EndTime.HasValue && entity.StartTime >= entity.EndTime)
            {
                throw new ArgumentException("StartTime must be before EndTime.");
            }

            return Task.CompletedTask;
        }

        protected override Task OnUpdating(Schedule entity, ScheduleUpdateRequest request)
        {
            var validDays = new[] { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
            if (!validDays.Contains(request.DayOfWeek))
            {
                throw new ArgumentException("Day of the week is invalid.");
            }

            if (request.StartTime.HasValue && request.EndTime.HasValue && request.StartTime >= request.EndTime)
            {
                throw new ArgumentException("StartTime must be before EndTime.");
            }

            return Task.CompletedTask;
        }

        public async Task<List<Model.Entities.Schedule>> GetOrganizationScheduleAsync(int organizationId)
        {
            var schedules = await _context.Set<Schedule>()
                .Where(x => x.OrganizationId == organizationId)
                .OrderBy(x => x.DayOfWeek)
                .ThenBy(x => x.StartTime)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Schedule>>(schedules);
        }

        public async Task<List<Model.Entities.Schedule>> GetScheduleByDayAsync(string dayOfWeek)
        {
            var schedules = await _context.Set<Schedule>()
                .Where(x => x.DayOfWeek == dayOfWeek)
                .OrderBy(x => x.StartTime)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Schedule>>(schedules);
        }

        public async Task<List<Model.Entities.Schedule>> GetScheduleByLocationAsync(int locationId)
        {
            var schedules = await _context.Set<Schedule>()
                .Where(x => x.LocationId == locationId)
                .OrderBy(x => x.DayOfWeek)
                .ThenBy(x => x.StartTime)
                .ToListAsync();

            return _mapper.Map<List<Model.Entities.Schedule>>(schedules);
        }
    }
}