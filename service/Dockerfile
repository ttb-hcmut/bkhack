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
CMD  ["mix", "run", "--no-halt", "-e", "App.start"]
