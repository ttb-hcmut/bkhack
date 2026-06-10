FROM elixir:1.18.4
ARG BKHACK_SUPABASE_PASSWORD='balls-penis-'
ENV BKHACK_SUPABASE_PASSWORD='balls-penis-'
COPY mix.exs ./mix.exs
COPY mix.lock ./mix.lock
COPY config ./config
COPY lib ./lib
RUN  mix deps.get
RUN  mix compile
EXPOSE 5000
# EXPOSE 4369 # XXX(kinten) Erlang Port Mapper
CMD  ["mix", "run", "--no-halt"]
## vi: set ft=dockerfile:
