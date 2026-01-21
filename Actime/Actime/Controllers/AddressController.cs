using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class AddressController : BaseCrudController<Address, TextSearchObject, AddressRequest, AddressRequest>
    {
        public AddressController(IAddressService addressService) : base(addressService)
        {
        }

        [AllowAnonymous]
        public override Task<PagedResult<Address>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<Address?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}