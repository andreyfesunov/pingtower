defmodule PingWorkers.Presentation.Requests.GetUrlsRequestModel do
  @moduledoc """
  Input model for 'WorkersRouter'. Used to get `Worker`.

  The module contains function to validate and create `GetUrlRequestModel`.
  """

  defstruct [:page, :page_size]

  @type t :: %__MODULE__{
          page: pos_integer(),
          page_size: pos_integer()
        }

  @spec new(map()) :: {:ok, t()} | {:error, String.t()}
  def new(params) when is_map(params) do
    with {:ok, page} <- parse_page(params),
         {:ok, page_size} <- parse_page_size(params) do
      {:ok, %__MODULE__{page: page, page_size: page_size}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_page(params) do
    case Map.get(params, "page", "1") do
      page when is_integer(page) and page > 0 ->
        {:ok, page}

      page_str when is_binary(page_str) ->
        case Integer.parse(page_str) do
          {page, ""} when page > 0 -> {:ok, page}
          _ -> {:error, "Invalid page parameter: must be a positive integer"}
        end

      _ ->
        {:error, "Invalid page parameter: must be a positive integer"}
    end
  end

  defp parse_page_size(params) do
    case Map.get(params, "page_size", "25") do
      page_size when is_integer(page_size) and page_size > 0 ->
        {:ok, page_size}

      page_size_str when is_binary(page_size_str) ->
        case Integer.parse(page_size_str) do
          {page_size, ""} when page_size > 0 -> {:ok, page_size}
          _ -> {:error, "Invalid page_size parameter: must be a positive integer"}
        end

      _ ->
        {:error, "Invalid page_size parameter: must be a positive integer"}
    end
  end
end
