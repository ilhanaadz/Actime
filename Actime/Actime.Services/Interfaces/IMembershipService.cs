using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IMembershipService : ICrudService<Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
    }
}
