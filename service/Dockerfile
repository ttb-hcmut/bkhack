FROM elixir:1.18.4
COPY mix.exs ./mix.exs
COPY lib ./lib
RUN  mix deps.get
RUN  mix compile
EXPOSE 5000
# below is for Erlang Port Mapper
EXPOSE 4369
CMD  iex --sname bkhack --cookie bkhack-INSERT_ID_HERE -S mix
