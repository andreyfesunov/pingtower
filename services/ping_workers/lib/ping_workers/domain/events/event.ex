defprotocol PingWorkers.Domain.Events.Event do
  @moduledoc """
  Protocol for domain events.

  All domain events must implement this protocol to provide
  routing information and payload for message publishing.
  """

  @doc """
  Returns the event type as an atom.
  """
  @spec event_type(t()) :: atom()
  def event_type(event)

  @doc """
  Returns the routing key for message routing.
  """
  @spec routing_key(t()) :: String.t()
  def routing_key(event)

  @doc """
  Returns the payload as a map.
  """
  @spec payload(t()) :: map()
  def payload(event)

  @doc """
  Returns the event version.
  """
  @spec version(t()) :: String.t()
  def version(event)
end
