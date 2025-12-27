using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Actime.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class ReportController : BaseCrudController<Report, ReportSearchObject, ReportInsertRequest, ReportUpdateRequest>
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService) : base(reportService)
        {
            _reportService = reportService ?? throw new ArgumentNullException(nameof(reportService));
        }

        [HttpGet("organization/{organizationId}")]
        public async Task<ActionResult<List<Report>>> GetOrganizationReports(int organizationId)
        {
            var reports = await _reportService.GetOrganizationReportsAsync(organizationId);
            return Ok(reports);
        }

        [HttpGet("type/{reportTypeId}")]
        public async Task<ActionResult<List<Report>>> GetReportsByType(int reportTypeId)
        {
            var reports = await _reportService.GetReportsByTypeAsync(reportTypeId);
            return Ok(reports);
        }
    }
}
