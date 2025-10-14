using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class AddressController : BaseCrudController<Address, TextSearchObject, AddressRequest, AddressRequest>
    {
        public AddressController(IAddressService addressService) : base(addressService)
        {
        }
    }
}