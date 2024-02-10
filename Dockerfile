FROM hexpm/elixir:1.16.1-erlang-25.3.2.9-alpine-3.19.1 as builder

RUN apk update && apk add git

WORKDIR /app

RUN mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/
RUN mix deps.compile

COPY lib lib
RUN mix compile

COPY config/runtime.exs config/

RUN mix release

FROM alpine:3.19.1

RUN apk update && apk add libncursesw libstdc++ libgcc

WORKDIR "/app"

ENV MIX_ENV="prod"

COPY --from=builder /app/_build/${MIX_ENV}/rel/crebito ./

CMD ["/bin/sh", "-c", "/app/bin/crebito start"]
