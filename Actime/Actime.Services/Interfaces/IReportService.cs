using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Services;

namespace Actime.Services.Interfaces
{
    public interface IReportService : ICrudService<Model.Entities.Report, ReportSearchObject, ReportInsertRequest, ReportUpdateRequest>
    {
        Task<List<Model.Entities.Report>> GetOrganizationReportsAsync(int organizationId);
        Task<List<Model.Entities.Report>> GetReportsByTypeAsync(int reportTypeId);
    }
}
