using Actime.Services.Database;
using Microsoft.AspNetCore.Identity;

namespace Actime
{
    public class SeedData
    {
        public static async Task Initialize(ActimeContext context, IServiceProvider services)
        {
            var roleManager = services.GetRequiredService<RoleManager<IdentityRole<int>>>();
            var userManager = services.GetRequiredService<UserManager<User>>();

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
                    new ActivityType { Name = "Camp" },
                    new ActivityType { Name = "Other" }
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
                    new Country { Name = "Bosnia and Herzegovina" },
                    new Country { Name = "Croatia" },
                    new Country { Name = "Serbia" }
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

            string[] roles = new[] { "Admin", "User" };
            foreach (var roleName in roles)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    await roleManager.CreateAsync(new IdentityRole<int>(roleName));
                }
            }

            if (!context.Users.Any())
            {
                var admin = new User
                {
                    UserName = "john.doe",
                    Email = "admin@actime.com",
                    FirstName = "John",
                    LastName = "Doe",
                    EmailConfirmed = true,
                    PhoneNumberConfirmed = true,
                    DateOfBirth = new DateTime(1990, 1, 1)
                };

                var result = await userManager.CreateAsync(admin, "Admin123!");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(admin, "Admin");
                }

                string[] firstNames = { "Jane", "Mia", "Joe", "Jack", "Michael", "Lea", "Sara", "Dino", "Ema", "Una" };
                string[] lastNames = { "Khan", "Connor", "Garcia", "Tanaka", "Popov", "Muller", "Zahra", "Silva", "Patel", "Andersson" };

                for (int i = 0; i < 10; i++)
                {
                    var user = new User
                    {
                        UserName = $"{firstNames[i].ToLower()}.{lastNames[i].ToLower()}",
                        Email = $"{firstNames[i].ToLower()}.{lastNames[i].ToLower()}@actime.com",
                        FirstName = firstNames[i],
                        LastName = lastNames[i],
                        EmailConfirmed = true,
                        PhoneNumberConfirmed = true,
                        DateOfBirth = new DateTime(1995 + i % 5, 1, (i % 28) + 1)
                    };

                    var userResult = await userManager.CreateAsync(user, "Actime123!");
                    if (userResult.Succeeded)
                    {
                        await userManager.AddToRoleAsync(user, "User");
                    }
                }
            }

            if (!context.Addresses.Any())
            {
                var streetNames = new[]
                {
                    "Baker Street", "Elm Street", "Fifth Avenue", "Main Street", "Sunset Boulevard",
                    "High Street", "Maple Avenue", "Park Lane", "Oxford Street", "King Street"
                };

                var postalCodes = new[]
                {
                    "10000", "71000", "75000", "88000", "11000", "20000", "51000", "31000", "18000", "34000"
                };

                var random = new Random();

                var addresses = new List<Address>();

                for (int i = 0; i < 10; i++)
                {
                    addresses.Add(new Address
                    {
                        Street = streetNames[i],
                        PostalCode = postalCodes[i],
                        Coordinates = $"{random.NextDouble() * 180 - 90},{random.NextDouble() * 360 - 180}",
                        CityId = random.Next(1, 5)
                    });
                }

                await context.Addresses.AddRangeAsync(addresses);
                await context.SaveChangesAsync();
            }

            if (!context.Organizations.Any())
            {
                context.Organizations.AddRange(
                    new Organization
                    {
                        Name = "Global Hiking Club",
                        Email = "info@globalhiking.com",
                        Description = "A community of nature lovers and adventure seekers.",
                        LogoUrl = "globalhiking.png",
                        PhoneNumber = "+12345678901",
                        CategoryId = 1,
                        AddressId = 1
                    },
                    new Organization
                    {
                        Name = "Sport for All Association",
                        Email = "contact@sportforall.org",
                        Description = "Promoting sports and healthy lifestyles worldwide.",
                        LogoUrl = "sportforall.png",
                        PhoneNumber = "+19876543210",
                        CategoryId = 2,
                        AddressId = 2
                    },
                    new Organization
                    {
                        Name = "FitLife Gym",
                        Email = "contact@fitlifegym.com",
                        Description = "Fitness center welcoming all ages and levels.",
                        LogoUrl = "fitlife.png",
                        PhoneNumber = "+10987654321",
                        CategoryId = 3,
                        AddressId = 3
                    }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Locations.Any())
            {
                context.Locations.AddRange(
                    new Location { AddressId = 1, Capacity = 100, Description = "Main hall", ContactInfo = "info@venue1.com" },
                    new Location { AddressId = 2, Capacity = 50, Description = "Cental stadium", ContactInfo = "contact@venue2.com" },
                    new Location { AddressId = 3, Capacity = 200, Description = "Outdoor stage", ContactInfo = "events@venue3.com" }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Events.Any())
            {
                context.Events.Add(
                    new Event
                    {
                        OrganizationId = 1,
                        Title = "Annual Hiking Trip",
                        Description = "Explore nature with us.",
                        Start = DateTime.Now.AddDays(10),
                        End = DateTime.Now.AddDays(12),
                        LocationId = 1,
                        MaxParticipants = 50,
                        IsFree = false,
                        Price = 100,
                        EventStatusId = 2,
                        ActivityTypeId = 1
                    }
                );

                await context.SaveChangesAsync();
            }

            if (!context.Memberships.Any())
            {
                context.Memberships.Add(new Membership { UserId = 2, OrganizationId = 1, MembershipStatusId = 2 });
                await context.SaveChangesAsync();
            }

            if (!context.Participations.Any())
            {
                context.Participations.Add(new Participation { UserId = 2, EventId = 1, AttendanceStatusId = 2 });
                await context.SaveChangesAsync();
            }

            if (!context.Reviews.Any())
            {
                context.Reviews.Add(new Review
                {
                    UserId = 2,
                    OrganizationId = 1,
                    Score = 5,
                    Text = "Great organization with amazing events!",
                    CreatedAt = DateTime.Now
                });

                await context.SaveChangesAsync();
            }

            if (!context.Schedules.Any())
            {
                context.Schedules.Add(new Schedule
                {
                    OrganizationId = 1,
                    DayOfWeek = "Monday",
                    StartTime = TimeOnly.Parse("08:00"),
                    EndTime = TimeOnly.Parse("16:00"),
                    ActivityTypeId = 1,
                    LocationId = 1,
                    Description = "Weekly hike."
                });

                await context.SaveChangesAsync();
            }
        }
    }
}