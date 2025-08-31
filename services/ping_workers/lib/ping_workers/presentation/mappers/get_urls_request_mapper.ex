defmodule PingWorkers.Presentation.Mappers.GetUrlsRequestMapper do
  @moduledoc """
  Mapper for map request models to `GetUrlsCommand`.
  """

  alias PingWorkers.Application.Commands.GetWorkersCommand
  alias PingWorkers.Presentation.Requests.GetUrlsRequestModel

  @spec map(GetUrlsRequestModel.t()) :: GetWorkersCommand.t()
  def map(model) do
    GetWorkersCommand.new(
      model.page,
      model.page_size
    )
  end
end
