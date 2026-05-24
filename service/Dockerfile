FROM elixir:1.18.4
COPY mix.exs ./mix.exs
COPY lib ./lib
RUN  mix deps.get
RUN  mix compile
EXPOSE 5000
# below is for Erlang Port Mapper
EXPOSE 4369
CMD  sh -c 'iex -S mix <<< \'App.start; defmodule A do def forever do Process.sleep(1000); forever() end end; A.forever()\''
