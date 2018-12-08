# Visual studio only use the first FROM
FROM microsoft/dotnet:2.1.6-aspnetcore-runtime-stretch-slim AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1.500-sdk-stretch AS build
WORKDIR /code
COPY ["*.sln", "."]
COPY ["src/Devcon.SampleSite/Devcon.SampleSite.csproj", "src/Devcon.SampleSite/"]
COPY ["src/Devcon.SampleLibrary/Devcon.SampleLibrary.csproj", "src/Devcon.SampleLibrary/"]
COPY ["tests/Devcon.SampleSite.UnitTests/Devcon.SampleSite.UnitTests.csproj", "tests/Devcon.SampleSite.UnitTests/"]
COPY ["tests/Devcon.SampleLibrary.UnitTests/Devcon.SampleLibrary.UnitTests.csproj", "tests/Devcon.SampleLibrary.UnitTests/"]
RUN dotnet restore
COPY . .
RUN dotnet build --configuration Release

# Run unit tests
FROM build AS testrunner
WORKDIR /code
ENTRYPOINT ["dotnet", "test", "/p:CollectCoverage=true", "--no-build", "--no-restore", "--configuration", "Release", "--logger", "trx", "--results-directory", "/code/test-results", "--verbosity", "normal"]

# Transform the result from VSTest format to JUnit format
FROM microsoft/dotnet:2.1.500-sdk-stretch AS testresulttransform
WORKDIR /code
RUN dotnet tool install -g trx2junit
ENV PATH="/root/.dotnet/tools:${PATH}"
ENTRYPOINT trx2junit /code/test-results/*.trx

# Publish & pack the application
FROM build AS publish
RUN dotnet publish --no-build --no-restore --configuration Release --output publish-output
RUN dotnet pack --no-build --no-restore --configuration Release --output nuget-output


# Final application
FROM base AS final
WORKDIR /app
COPY --from=publish /code/src/Devcon.SampleSite/publish-output .
ENTRYPOINT ["dotnet", "Devcon.SampleSite.dll"]