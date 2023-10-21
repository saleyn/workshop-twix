# Twix

This project illustrates features of Phoenix/LiveView that include

  * LiveView form editing with validation
  * PubSub subscriptions
  * Broadcasting events and viewing updates reactively in real-time
  * Progressive scrolling of large data sets

The project shows the power of Phoenix/LiveView development that allows
to implement sophisticated logic rapidly using a single language without
needing to add any Javascript.

It is a more advanced and updated version of Chris McCord's post
https://www.youtube.com/watch?v=MZvmYaFkNJI.

## Installation

- To install Erlang/Elixir use the [asdf](https://asdf-vm.com/guide/getting-started.html) tool.

  * Install `asdf`:
  ```bash
  $ git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
  ```
  * Add asdf environment to `~/.bashrc`:
  ```bash
  . "$HOME/.asdf/asdf.sh"
  . "$HOME/.asdf/completions/asdf.bash"
  ```

  * Install Erlang/Elixir plugins for asdf
  ```bash
  $ asdf plugin add erlang
  $ asdf plugin add elixir
  ```

  * Install the latest version of Erlang and Elixir
  ```bash
  $ asdf install erlang latest
  $ asdf install elixir latest
  ```

- Install Phoenix/LiveView

  ```bash
  $ mix archive.install phx_new
  ```

- This project uses Postgres database. If you don't have it installed,
  install it on your system with your favorite installation method. On Arch
  Linux this can be accomplished by running `sudo pacman -S postgres`.
  Alternatively you can use `docker`:
  ```bash
  $ docker pull postgres
  $ docker run --name postgres -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres-passwd -d postgres
  ```

To bootstrap the database and start your Phoenix server interactively, run:

  ```bash
  $ mix setup
  $ make run
  ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Seeding some sample data

The following command will add 100 new posts:

```bash
$ mix run priv/repo/seeds.exs
```

## Generating a new Phoenix project from scratch

This project was created from a mix template using:

```bash
$ mix phx.new twix --live
$ mix phx.gen.live Timeline Post posts username body likes_count:integer repost_count:integer
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
  * Cris McCord's post that inspired this project:
    https://www.youtube.com/watch?v=MZvmYaFkNJI
