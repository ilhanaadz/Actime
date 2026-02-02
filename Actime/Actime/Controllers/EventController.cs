using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Actime.Controllers
{
    public class EventController : BaseCrudController<Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>
    {
        private readonly IEventService _eventService;
        private readonly IOrganizationService _organizationService;

        public EventController(IEventService eventService, IOrganizationService organizationService) : base(eventService)
        {
            _eventService = eventService;
            _organizationService = organizationService;
        }

        [AllowAnonymous]
        public override Task<PagedResult<Event>> Get([FromQuery] EventSearchObject? search = null)
        {
            search ??= new EventSearchObject();

            // Admins can see all events including pending
            // Anonymous users cannot see pending events
            // Regular authenticated users can see pending events of their own organization
            if (!User.Identity?.IsAuthenticated ?? true)
            {
                search.ExcludePending = true;
            }

            // Set current user ID for IsEnrolled check
            search.CurrentUserId = GetCurrentUserId();

            return base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<Event?> GetById(int id)
        {
            var currentUserId = GetCurrentUserId();
            return await _eventService.GetByIdAsync(id, currentUserId);
        }

        [AllowAnonymous]
        public override Task<Event> Create([FromBody] EventInsertRequest request)
        {
            return base.Create(request);
        }

        public override async Task<Event?> Update(int id, [FromBody] EventUpdateRequest request)
        {
            // Only organization owner can update their events (admins cannot edit)
            var existingEvent = await _eventService.GetByIdAsync(id);
            if (existingEvent == null)
                return null;

            var userId = GetCurrentUserId();
            if (userId == null)
                throw new UnauthorizedAccessException("User not authenticated.");

            var userOwnsOrganization = await _organizationService.UserOwnsOrganizationAsync(userId.Value, existingEvent.OrganizationId);
            if (!userOwnsOrganization)
                throw new UnauthorizedAccessException("You can only modify events created by your organization.");

            return await base.Update(id, request);
        }

        public override async Task<bool> Delete(int id)
        {
            // Admins can delete any event
            if (IsAdmin())
                return await base.Delete(id);

            // Verify user owns the event's organization
            var existingEvent = await _eventService.GetByIdAsync(id);
            if (existingEvent == null)
                return false;

            var userId = GetCurrentUserId();
            if (userId == null)
                throw new UnauthorizedAccessException("User not authenticated.");

            var userOwnsOrganization = await _organizationService.UserOwnsOrganizationAsync(userId.Value, existingEvent.OrganizationId);
            if (!userOwnsOrganization)
                throw new UnauthorizedAccessException("You can only delete events created by your organization.");

            return await base.Delete(id);
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(userIdClaim, out var userId) ? userId : null;
        }

        private bool IsAdmin()
        {
            return User.IsInRole("Admin") || User.IsInRole("admin");
        }
    }
}