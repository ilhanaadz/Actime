using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IAddressService : ICrudService<Address, TextSearchObject, AddressRequest, AddressRequest>
    {
    }
}