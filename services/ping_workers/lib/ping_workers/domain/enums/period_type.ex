defmodule PingWorkers.Domain.Enums.PeriodType do
  @moduledoc """
  Period for `Worker`. It can be: minute, hour, day, week, month.

  The module contains functions to convert between period type and string.
  """

  @type t :: :minute | :hour | :day | :week | :month

  @values [:minute, :hour, :day, :week, :month]

  @spec values() :: [t(), ...]
  def values, do: @values

  @spec from_string(String.t()) :: t() | nil
  def from_string(period_str) when is_binary(period_str) do
    case period_str do
      "minute" -> :minute
      "hour" -> :hour
      "day" -> :day
      "week" -> :week
      "month" -> :month
      _ -> nil
    end
  end
end

defimpl String.Chars, for: PingWorkers.Domain.Enums.PeriodType do
  def to_string(type) do
    Atom.to_string(type)
  end
end
