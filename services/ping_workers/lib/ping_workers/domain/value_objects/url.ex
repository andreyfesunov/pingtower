defmodule PingWorkers.Domain.ValueObjects.Url do
  @moduledoc """
  Value Object for URL validtion.
  """

  defstruct [:value]

  @type t :: %__MODULE__{
          value: String.t()
        }

  @spec new(String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(url) when is_binary(url) do
    case validate_url(url) do
      true -> {:ok, %__MODULE__{value: normalize_url(url)}}
      false -> {:error, "Invalid URL format"}
    end
  end

  def new(_), do: {:error, "URL must be a string"}

  @spec validate_url(String.t()) :: boolean()
  defp validate_url(url) do
    uri = URI.parse(url)
    uri.scheme in ["http", "https"] && uri.host != nil
  rescue
    URI.Error -> false
  end

  @spec normalize_url(String.t()) :: String.t()
  defp normalize_url(url) do
    url
    |> String.trim()
    |> String.downcase()
  end

  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{} = url), do: url.value

  @spec get_domain(t()) :: String.t()
  def get_domain(%__MODULE__{} = url), do: URI.parse(url.value).host

  @spec get_scheme(t()) :: String.t()
  def get_scheme(%__MODULE__{} = url), do: URI.parse(url.value).scheme
end

defimpl String.Chars, for: PingWorkers.Domain.ValueObjects.Url do
  def to_string(%{value: value}), do: value
end
