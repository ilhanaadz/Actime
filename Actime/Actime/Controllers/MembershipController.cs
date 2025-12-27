using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class MembershipController : BaseCrudController<Membership, MembershipSearchObject, MembershipInsertRequest, MembershipUpdateRequest>
    {
        public MembershipController(IMembershipService membershipService) : base(membershipService)
        {
        }
    }
}
