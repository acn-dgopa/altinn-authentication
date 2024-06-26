FROM mcr.microsoft.com/dotnet/sdk:8.0.204-alpine3.18 AS build
WORKDIR AuthenticationApp/


COPY src/ ./src

RUN dotnet restore ./src/Authentication/Altinn.Platform.Authentication.csproj

RUN dotnet build ./src/Authentication/Altinn.Platform.Authentication.csproj -c Release -o /app_output

RUN dotnet publish ./src/Authentication/Altinn.Platform.Authentication.csproj -c Release -o /app_output

FROM mcr.microsoft.com/dotnet/aspnet:8.0.4-alpine3.18 AS final
EXPOSE 5040
WORKDIR /app
COPY --from=build /app_output .

# setup the user and group
# the user will have no password, using shell /bin/false and using the group dotnet
RUN addgroup -g 3000 dotnet && adduser -u 1000 -G dotnet -D -s /bin/false dotnet
# update permissions of files if neccessary before becoming dotnet user
USER dotnet
RUN mkdir /tmp/logtelemetry

ENTRYPOINT ["dotnet", "Altinn.Platform.Authentication.dll"]
