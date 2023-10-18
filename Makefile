all: deps compile

deps:
	mix deps.get

compile setup:
	mix $@

run:
	iex -S mix phx.server

.PHONY: deps
