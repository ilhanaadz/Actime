using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class EventService : BaseCrudService<Model.Entities.Event, TextSearchObject, Event, EventInsertRequest, EventUpdateRequest>, IEventService
    {
        public EventService(ActimeContext context, Mapper mapper) : base(context, mapper)
        {
        }
    }
}
