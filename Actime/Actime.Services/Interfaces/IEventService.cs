using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IEventService : ICrudService<Event, TextSearchObject, EventInsertRequest, EventUpdateRequest>
    {
    }
}
