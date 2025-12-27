using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class ScheduleController : BaseCrudController<Schedule, ScheduleSearchObject, ScheduleInsertRequest, ScheduleUpdateRequest>
    {
        private readonly IScheduleService _scheduleService;

        public ScheduleController(IScheduleService scheduleService) : base(scheduleService)
        {
            _scheduleService = scheduleService ?? throw new ArgumentNullException(nameof(scheduleService));
        }

        [HttpGet("organization/{organizationId}")]
        public async Task<ActionResult<List<Schedule>>> GetOrganizationSchedule(int organizationId)
        {
            var schedules = await _scheduleService.GetOrganizationScheduleAsync(organizationId);
            return Ok(schedules);
        }

        [HttpGet("day/{dayOfWeek}")]
        public async Task<ActionResult<List<Schedule>>> GetScheduleByDay(string dayOfWeek)
        {
            var schedules = await _scheduleService.GetScheduleByDayAsync(dayOfWeek);
            return Ok(schedules);
        }

        [HttpGet("location/{locationId}")]
        public async Task<ActionResult<List<Schedule>>> GetScheduleByLocation(int locationId)
        {
            var schedules = await _scheduleService.GetScheduleByLocationAsync(locationId);
            return Ok(schedules);
        }
    }
}