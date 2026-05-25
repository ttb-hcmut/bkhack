FROM elixir:1.18.4
ARG BKHACK_SUPABASE_PASSWORD
ENV BKHACK_SUPABASE_PASSWORD=$BKHACK_SUPABASE_PASSWORD
COPY mix.exs ./mix.exs
COPY config ./config
COPY lib ./lib
RUN  mix deps.get
RUN  mix compile
EXPOSE 5000
# below is for Erlang Port Mapper
EXPOSE 4369
CMD  ["sh", "-c", "echo 'App.start; defmodule A do def forever do Process.sleep(1000); forever() end end; A.forever()' | iex -S mix"]
