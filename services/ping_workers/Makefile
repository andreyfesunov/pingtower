.PHONY: setup run iex compile release clean

setup:
	mix deps.get

compile:
	mix compile

run:
	mix run --no-halt

iex:
	iex -S mix

release:
	MIX_ENV=prod mix release

clean:
	mix clean
	rm -rf _build deps

