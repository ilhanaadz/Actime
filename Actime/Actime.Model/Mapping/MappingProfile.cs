using Actime.Model.Entities;
using Actime.Model.Requests;
using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Actime.Model.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            //CreateMap<User, User>()
            //    .ForMember(dest => dest.Roles, opt => opt.Ignore());

            //CreateMap<Organization, OrganizationDto>()
            //    .ForMember(dest => dest.CreatedByUserName, opt => opt.Ignore());

            //CreateMap<Category, CategoryDto>();
            //CreateMap<Address, AddressDto>();
            //CreateMap<AddressRequest, Address>();
        }
    }
}
