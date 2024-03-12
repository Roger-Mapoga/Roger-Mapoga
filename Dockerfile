#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["FrontendHost/nuget.config", "FrontendHost/"]
COPY ["FrontendHost/FrontendHost.csproj", "FrontendHost/"]


# Install Node.js and npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs


RUN dotnet restore "./FrontendHost/./FrontendHost.csproj"   --source "https://nuget.pkg.github.com/doosy-sa/index.json" --source "https://api.nuget.org/v3/index.json"


# Verify Node.js installation
RUN node --version
#
## Install npm dependencies
#RUN npm install

COPY . .
WORKDIR "/src/FrontendHost"

 

RUN dotnet build "./FrontendHost.csproj" -c $BUILD_CONFIGURATION -o /app/build   --source "https://nuget.pkg.github.com/doosy-sa/index.json" --source "https://api.nuget.org/v3/index.json"




FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish  -o /app/publish 

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FrontendHost.dll"]