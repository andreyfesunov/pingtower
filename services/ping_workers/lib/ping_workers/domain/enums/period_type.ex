defmodule PingWorkers.Domain.Enums.PeriodType do
  @moduledoc """
  Period for `Worker`. It can be: minute, hour, day, week, month.

  The module contains functions to convert between period type and string.
  """

  @type t :: :minute | :hour | :day | :week | :month

  @values [:minute, :hour, :day, :week, :month]

  @spec values() :: [t(), ...]
  def values, do: @values

  @spec from_string(String.t()) :: {:ok, t()} | {:error, String.t()}
  def from_string(period_str) when is_binary(period_str) do
    case period_str do
      "minute" -> {:ok, :minute}
      "hour" -> {:ok, :hour}
      "day" -> {:ok, :day}
      "week" -> {:ok, :week}
      "month" -> {:ok, :month}
      _ -> {:error, "Invalid period"}
    end
  end

  @doc """
  Returns the period in seconds.
  """
  @spec period_in_seconds(:day | :hour | :minute | :month | :week) ::
          60 | 3600 | 86_400 | 604_800 | 2_629_746
  def period_in_seconds(period) do
    case period do
      :minute -> 60
      :hour -> 3600
      :day -> 86_400
      :week -> 604_800
      :month -> 2_629_746
    end
  end
end

defimpl String.Chars, for: PingWorkers.Domain.Enums.PeriodType do
  def to_string(type) do
    Atom.to_string(type)
  end
end
