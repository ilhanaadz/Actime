# Actime API - Multi-stage Docker build
# Build from solution root: docker build -t actime-api .

# ============================================
# Stage 1: Base runtime image
# ============================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# ============================================
# Stage 2: Build
# ============================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy all project files first (for better layer caching)
COPY ["Actime/Actime.csproj", "Actime/"]
COPY ["Actime.Model/Actime.Model.csproj", "Actime.Model/"]
COPY ["Actime.Services/Actime.Services.csproj", "Actime.Services/"]

# Restore dependencies
RUN dotnet restore "Actime/Actime.csproj"

# Copy everything else
COPY . .

# Build the project
WORKDIR "/src/Actime"
RUN dotnet build "Actime.csproj" -c $BUILD_CONFIGURATION -o /app/build

# ============================================
# Stage 3: Publish
# ============================================
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Actime.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# ============================================
# Stage 4: Final runtime image
# ============================================
FROM base AS final
WORKDIR /app

# Copy published app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "Actime.dll"]
