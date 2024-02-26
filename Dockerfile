# ---------------------------------------------------------#
# Build Release                                            #
# ---------------------------------------------------------#
FROM hexpm/elixir:1.16.1-erlang-26.2.2-debian-bullseye-20240130-slim as build

RUN apt-get update -y && apt-get install -y build-essential wget ca-certificates && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

ARG PUID=1000
ARG PGID=1000
ARG HOME="/app"

RUN addgroup --gid ${PGID} rinha_backend
RUN adduser --system --home ${HOME} --ingroup rinha_backend --uid ${PUID} rinha_backend

USER rinha_backend

# Prepare build dir
WORKDIR ${HOME}

# Set build ENV
ENV MIX_ENV=prod

# Installing Elixir Dependencies
RUN mix local.hex --force && \
    mix local.rebar --force


# Install and compile mix dependencies
COPY --chown=rinha_backend:rinha_backend mix.exs mix.lock ./
COPY --chown=rinha_backend:rinha_backend config/config.exs config/${MIX_ENV}.exs config/

RUN mix do deps.get --only $MIX_ENV, deps.compile

# Copy the rest of the files
COPY --chown=rinha_backend:rinha_backend . .

# Compile the project
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Copies seed file
COPY priv/repo/seeds.exs .

# Build Release
RUN mix release --quiet --path release

# Copy release commands
RUN mkdir -p release/bin/commands
RUN cp rel/commands/* release/bin/commands

# ---------------------------------------------------------#
# Run Release                                              #
# ---------------------------------------------------------#
FROM debian:bullseye-20240130-slim as app

RUN apt-get update -y && \
    apt-get install -y libstdc++6 libncurses5 openssl locales tini ca-certificates tini tzdata && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
  && echo "America/Sao_Paulo" > /etc/timezone

ENV LANG=C.UTF-8

ARG PUID=1000
ARG PGID=1000
ARG HOME="/app"

RUN addgroup --gid ${PGID} rinha_backend
RUN adduser --system --home ${HOME} --ingroup rinha_backend --uid ${PUID} rinha_backend

USER rinha_backend
WORKDIR /app

RUN chown rinha_backend:rinha_backend /app

# Copy artifact from build
COPY --from=build --chown=rinha_backend:rinha_backend /app/release ./

# Make release commands available
RUN chmod u+x /app/bin/commands/*
ENV PATH=/app/bin/commands:$PATH

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/app/bin/rinha_backend", "start"]
