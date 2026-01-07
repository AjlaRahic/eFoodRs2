#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
 
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 7072
ENV ASPNETCORE_URLS=https://+:7072
 
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
 
COPY ["eFood.Subscriber/eFood.Subscriber.csproj", "eFood.Subscriber/"]
RUN dotnet restore "eFood.Subscriber/eFood.Subscriber.csproj"
 
COPY . .
WORKDIR "/src/eFood.Subscriber"
RUN dotnet build "eFood.Subscriber.csproj" -c Release -o /app/build
 
 
FROM build AS publish
RUN dotnet publish "eFood.Subscriber.csproj" -c Release -o /app
 
FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "eFood.Subscriber.dll"]