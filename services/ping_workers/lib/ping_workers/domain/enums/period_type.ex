defmodule PingWorkers.Domain.Enums.PeriodType do
  @type t :: :minute | :hour | :day | :week | :month

  @periods [:minute, :hour, :day, :week, :month]

  @spec values() :: [t()]
  def values, do: @periods

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
