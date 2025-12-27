using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IScheduleService : ICrudService<Schedule, ScheduleSearchObject, ScheduleInsertRequest, ScheduleUpdateRequest>
    {
        Task<List<Schedule>> GetOrganizationScheduleAsync(int organizationId);
        Task<List<Schedule>> GetScheduleByDayAsync(string dayOfWeek);
        Task<List<Schedule>> GetScheduleByLocationAsync(int locationId);
    }
}
