using Actime.Model.Common;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    //NOTE: Pay attention to ApiController attribute, it enables automatic model validation and other features.
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;

        public BaseController(IService<T, TSearch> service)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
        }

        [HttpGet]
        public virtual async Task<PagedResult<T>> Get([FromQuery] TSearch? search = null) => await _service.GetAsync(search ?? new TSearch());

        [HttpGet("{id}")]
        public virtual async Task<T?> GetById(int id) => await _service.GetByIdAsync(id);
    }
}
