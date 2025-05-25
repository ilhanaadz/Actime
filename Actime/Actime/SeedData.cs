using Actime.Services.Database;
using Microsoft.AspNetCore.Identity;

namespace Actime
{
    public class SeedData
    {
        public static async Task Initialize(ActimeContext context, IServiceProvider services)
        {
            // Ensure the database is created
            await context.Database.EnsureCreatedAsync();

            // Seed initial data if necessary
            if (!context.ActivityTypes.Any())
            {
                await context.ActivityTypes.AddRangeAsync(
                new ActivityType { Name = "SingleDayTrip" },
                        new ActivityType { Name = "MultiDayTrip" },
                        new ActivityType { Name = "Training" },
                        new ActivityType { Name = "Match" },
                        new ActivityType { Name = "Meeting" },
                        new ActivityType { Name = "Volunteering" },
                        new ActivityType { Name = "Fundraising" },
                        new ActivityType { Name = "AidCampaign" },
                        new ActivityType { Name = "TeamBuilding" },
                        new ActivityType { Name = "Promotion" },
                        new ActivityType { Name = "Competition" },
                        new ActivityType { Name = "Celebration" },
                        new ActivityType { Name = "Workshop" },
                        new ActivityType { Name = "RecruitmentEvent" },
                        new ActivityType { Name = "Camp" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.AttendanceStatuses.Any())
            {
                await context.AttendanceStatuses.AddRangeAsync(
                   new AttendanceStatus { Name = "PendingResponse" },
                    new AttendanceStatus { Name = "Going" },
                    new AttendanceStatus { Name = "Maybe" },
                    new AttendanceStatus { Name = "NotGoing" },
                    new AttendanceStatus { Name = "Attended" },
                    new AttendanceStatus { Name = "Missed" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.EventStatuses.Any())
            {
                //TODO: Use await here or not?
                await context.EventStatuses.AddRangeAsync(
                new EventStatus { Name = "Pending" },
                    new EventStatus { Name = "Upcoming" },
                    new EventStatus { Name = "InProgress" },
                    new EventStatus { Name = "Completed" },
                    new EventStatus { Name = "Cancelled" },
                    new EventStatus { Name = "Postponed" },
                    new EventStatus { Name = "Rescheduled" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.MembershipStatuses.Any())
            {
                await context.MembershipStatuses.AddRangeAsync(
                    new MembershipStatus { Name = "Pending" },
                    new MembershipStatus { Name = "Active" },
                    new MembershipStatus { Name = "Suspended" },
                    new MembershipStatus { Name = "Cancelled" },
                    new MembershipStatus { Name = "Expired" },
                    new MembershipStatus { Name = "Rejected" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.PaymentMethods.Any())
            {
                await context.PaymentMethods.AddRangeAsync(
                    new PaymentMethod { Name = "Cash" },
                    new PaymentMethod { Name = "CreditCard" },
                    new PaymentMethod { Name = "BankTransfer" },
                    new PaymentMethod { Name = "PayPal" },
                    new PaymentMethod { Name = "Invoice" },
                    new PaymentMethod { Name = "Other" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.PaymentStatuses.Any())
            {
                await context.PaymentStatuses.AddRangeAsync(
                    new PaymentStatus { Name = "Pending" },
                    new PaymentStatus { Name = "Paid" },
                    new PaymentStatus { Name = "Failed" },
                    new PaymentStatus { Name = "Refunded" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.ReportTypes.Any())
            {
                await context.ReportTypes.AddRangeAsync(
                   new ReportType { Name = "Activity" },
                    new ReportType { Name = "Memberships" },
                    new ReportType { Name = "Participations" },
                    new ReportType { Name = "Fundraising" },
                    new ReportType { Name = "Feedback" },
                    new ReportType { Name = "Events" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Categories.Any())
            {
                await context.Categories.AddRangeAsync(
                   new Category { Name = "Hiking" },
                    new Category { Name = "Football" },
                    new Category { Name = "Volleyball" },
                    new Category { Name = "Fitness" },
                    new Category { Name = "Basketball" },
                    new Category { Name = "Tennis" },
                    new Category { Name = "Alpinism" },
                    new Category { Name = "Skiing" },
                    new Category { Name = "Running" },
                    new Category { Name = "Boxing" },
                    new Category { Name = "Other" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Countries.Any())
            {
                await context.Countries.AddRangeAsync(
                   new Country { Id = 1, Name = "Bosnia and Herzegovina" },
                    new Country { Id = 2, Name = "Croatia" },
                    new Country { Id = 3, Name = "Serbia" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Cities.Any())
            {
                await context.Cities.AddRangeAsync(
                   new City { Name = "Sarajevo", CountryId = 1 },
                    new City { Name = "Mostar", CountryId = 1 },
                    new City { Name = "Zagreb", CountryId = 2 },
                    new City { Name = "Belgrade", CountryId = 3 }
                );

                await context.SaveChangesAsync();
            }

            //Seed roles and admin user using UserManager and RoleManager
            var roleManager = services.GetRequiredService<RoleManager<IdentityRole<int>>>();
            var userManager = services.GetRequiredService<UserManager<User>>();

            string[] roles = new[] { "Admin", "User" };
            foreach (var roleName in roles)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    var role = new IdentityRole<int>(roleName);
                    await roleManager.CreateAsync(role);
                }
            }

            string adminEmail = "admin@actime.com";
            string adminPassword = "Actime123!"; //Koristi config?

            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            if (adminUser == null)
            {
                adminUser = new User
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    EmailConfirmed = true,
                    FirstName = "John",
                    LastName = "Doe",
                    CreatedAt = DateTime.Now
                };

                var result = await userManager.CreateAsync(adminUser, adminPassword);
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(adminUser, "Admin");
                }
                else
                {
                    throw new Exception("Seed admin user creation failed: " + string.Join(", ", result.Errors.Select(e => e.Description)));
                }
            }

            //TODO: Create admin user, multiple basic users, organizations, events, etc. (check what is required)
            //TODO: Use ASP.NET Core Identity for user management.
        }
    }
}