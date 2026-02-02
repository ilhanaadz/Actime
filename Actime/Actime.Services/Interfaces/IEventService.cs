using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IEventService : ICrudService<Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>
    {
        /// <summary>
        /// Gets event by ID with IsEnrolled populated for the specified user.
        /// </summary>
        Task<Event?> GetByIdAsync(int id, int? currentUserId);
    }
}
