using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IParticipationService : ICrudService<Participation, ParticipationSearchObject, ParticipationInsertRequest, ParticipationUpdateRequest>
    {
        Task<bool> UpdateAttendanceStatusAsync(int id, int attendanceStatusId);
        Task<bool> UpdatePaymentStatusAsync(int id, int paymentStatusId);
        Task<int> GetEventParticipantCountAsync(int eventId);
        Task<List<Participation>> GetUserParticipationsAsync(int userId);
    }
}
