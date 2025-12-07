using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class EventController : BaseCrudController<Event, TextSearchObject, EventInsertRequest, EventUpdateRequest>
    {
        public EventController(IEventService eventService) : base(eventService)
        {
        }
    }
}