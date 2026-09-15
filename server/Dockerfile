FROM dart:stable AS build

WORKDIR /app
COPY pubspec.yaml ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o bin/server_exe

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server_exe /app/bin/server

EXPOSE 8000
CMD ["/app/bin/server"]
