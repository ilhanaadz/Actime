using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class EventController : BaseCrudController<Event, TextSearchObject, EventInsertRequest, EventUpdateRequest>
    {
        public EventController(IEventService eventService) : base(eventService)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<Event>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<Event?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}