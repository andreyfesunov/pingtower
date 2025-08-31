defmodule PingWorkers.Domain.Models.Pagination do
  @moduledoc """
  Generic pagination model for any type of items.
  """

  @type t(item_type) :: %__MODULE__{
          items: [item_type],
          page: pos_integer(),
          page_size: pos_integer(),
          total: non_neg_integer(),
          pages: pos_integer(),
          has_next: boolean(),
          has_prev: boolean()
        }

  defstruct [:items, :page, :page_size, :total, :pages, :has_next, :has_prev]

  @spec new([any()], pos_integer(), pos_integer(), non_neg_integer()) :: t(any())
  def new(items, page, page_size, total) do
    pages = calculate_pages(total, page_size)

    %__MODULE__{
      items: items,
      page: page,
      page_size: page_size,
      total: total,
      pages: pages,
      has_next: page < pages,
      has_prev: page > 1
    }
  end

  @spec empty(pos_integer(), pos_integer()) :: t(any())
  def empty(page, page_size) do
    new([], page, page_size, 0)
  end

  @spec to_map(t(any())) :: map()
  def to_map(pagination) do
    %{
      items: pagination.items,
      pagination: %{
        page: pagination.page,
        page_size: pagination.page_size,
        total: pagination.total,
        pages: pagination.pages,
        has_next: pagination.has_next,
        has_prev: pagination.has_prev
      }
    }
  end

  @doc """
  Maps items using a callback function and returns a new Pagination with transformed items.

  ## Examples

      iex> pagination = Pagination.new([%{id: 1, name: "test"}], 1, 10, 1)
      iex> mapped = Pagination.mapped(pagination, &(&1.id))
      iex> mapped.items
      [1]
      
      iex> pagination = Pagination.new([%Worker{id: uuid, url: url}], 1, 10, 1)
      iex> mapped = Pagination.mapped(pagination, &%{id: &1.id, url: &1.url})
      iex> mapped.items
      [%{id: uuid, url: url}]
  """
  @type mapper_callback(item_type, mapped_type) :: (item_type -> mapped_type)

  @spec mapped(t(item_type), mapper_callback(item_type, mapped_type)) :: t(mapped_type)
        when item_type: any(), mapped_type: any()
  def mapped(pagination, mapper_callback) do
    mapped_items = Enum.map(pagination.items, mapper_callback)

    %__MODULE__{
      items: mapped_items,
      page: pagination.page,
      page_size: pagination.page_size,
      total: pagination.total,
      pages: pagination.pages,
      has_next: pagination.has_next,
      has_prev: pagination.has_prev
    }
  end

  defp calculate_pages(total, _page_size) when total <= 0, do: 1
  defp calculate_pages(total, page_size) when total > 0, do: ceil(total / page_size)
end

defimpl Jason.Encoder, for: PingWorkers.Domain.Models.Pagination do
  def encode(pagination, opts) do
    %{
      items: pagination.items,
      pagination: %{
        page: pagination.page,
        page_size: pagination.page_size,
        total: pagination.total,
        pages: pagination.pages,
        has_next: pagination.has_next,
        has_prev: pagination.has_prev
      }
    }
    |> Jason.Encode.map(opts)
  end
end
