defmodule PingWorkers.Application.Commands.GetWorkersCommand do
  @moduledoc """
  Command for getting `GetWorkersUsecase`.
  """

  @type t :: %__MODULE__{
          page: pos_integer(),
          page_size: pos_integer()
        }

  defstruct [:page, :page_size]

  @spec new(pos_integer(), pos_integer()) :: t()
  def new(page, page_size) do
    %__MODULE__{page: page, page_size: page_size}
  end
end
