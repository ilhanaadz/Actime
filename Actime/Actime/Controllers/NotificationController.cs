using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Actime.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class NotificationController : BaseCrudController<Notification, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        private readonly INotificationService _notificationService;
        
        public NotificationController(INotificationService notificationService) : base(notificationService)
        {            
            _notificationService = notificationService ?? throw new ArgumentNullException(nameof(notificationService));
        }

        [HttpPut("{id}/mark-as-read")]
        public async Task<ActionResult<bool>> MarkAsRead(int id)
        {
            var result = await _notificationService.MarkAsReadAsync(id);
            if (!result)
                return NotFound();

            return Ok(result);
        }

        [HttpPut("mark-all-as-read/{userId}")]
        public async Task<ActionResult<bool>> MarkAllAsRead(int userId)
        {
            var result = await _notificationService.MarkAllAsReadAsync(userId);
            return Ok(result);
        }

        [HttpGet("unread-count/{userId}")]
        public async Task<ActionResult<int>> GetUnreadCount(int userId)
        {
            var count = await _notificationService.GetUnreadCountAsync(userId);
            return Ok(count);
        }
    }
}
