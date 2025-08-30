defmodule PingWorkers.Domain.ValueObjects.Uuid do
  @moduledoc """
  Value Object for UUID validation.
  """

  @type t :: <<_::288>>

  @spec new() :: t()
  def new, do: UUID.uuid4()

  def from_string(string) when is_binary(string) do
    if valid?(string) do
      {:ok, string}
    else
      {:error, "Invalid UUID format"}
    end
  end

  @spec valid?(any()) :: boolean()
  def valid?(<<_::binary-size(36)>>), do: true
  def valid?(_), do: false
end

defimpl String.Chars, for: PingWorkers.Domain.ValueObjects.Uuid do
  def to_string(uuid), do: uuid
end
