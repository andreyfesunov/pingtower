defmodule PingWorkersTest do
  use ExUnit.Case
  doctest PingWorkers

  test "greets the world" do
    assert PingWorkers.hello() == :world
  end
end
