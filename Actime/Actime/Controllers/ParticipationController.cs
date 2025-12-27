using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class ParticipationController : BaseCrudController<Participation, ParticipationSearchObject, ParticipationInsertRequest, ParticipationUpdateRequest>
    {
        private  readonly IParticipationService _participationService;

        public ParticipationController(IParticipationService participationService) : base(participationService)
        {
            _participationService = participationService ?? throw new ArgumentNullException(nameof(participationService));
        }

        [HttpPut("{id}/attendance-status/{attendanceStatusId}")]
        public async Task<ActionResult<bool>> UpdateAttendanceStatus(int id, int attendanceStatusId)
        {
            var result = await _participationService.UpdateAttendanceStatusAsync(id, attendanceStatusId);
            if (!result)
                return NotFound();

            return Ok(result);
        }

        [HttpPut("{id}/payment-status/{paymentStatusId}")]
        public async Task<ActionResult<bool>> UpdatePaymentStatus(int id, int paymentStatusId)
        {
            var result = await _participationService.UpdatePaymentStatusAsync(id, paymentStatusId);
            if (!result)
                return NotFound();

            return Ok(result);
        }

        [HttpGet("event/{eventId}/count")]
        public async Task<ActionResult<int>> GetEventParticipantCount(int eventId)
        {
            var count = await _participationService.GetEventParticipantCountAsync(eventId);
            return Ok(count);
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<Participation>>> GetUserParticipations(int userId)
        {
            var participations = await _participationService.GetUserParticipationsAsync(userId);
            return Ok(participations);
        }
    }
}