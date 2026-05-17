During development, it's sometimes useful to perform direct data binding. No algebraization or typing of values. No responsibility designation or MVC separation. At least, not yet. Consider a problem where the service API needs to specialize for the front-end's (technical) use case, but the front-end is still too early in development for any use case to be known.

Staying true to the nature of the architecture of our system, which is service-oriented architecture, we build a uniform abstraction to support as many diverse service backends as possible.

|                  | NoSQL (mongodb) | NoSQL (firestore) | SQL (supabase) | SQL (SQLite)  |
|------------------|-----------------|-------------------|----------------|---------------|
| gateway ecto     | n               | n                 | y              | y             |
| gateway direct   | y               | y[^ecto-firestore]| y              | y             |
| free sql         | n               | n                 | y              | y             |
| api direct       | n               | y                 | n              | n             |
| free sql direct  | n               | y                 | n              | n             |

[^ecto-firestore]: For Elixir, a firestore binding elixir-firestore.
