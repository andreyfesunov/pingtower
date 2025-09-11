defmodule PingWorkers.Domain.Models.PingData do
  @moduledoc """
  Data structure for pinging workers.
  """

  defstruct [
    :url,
    :request_time,
    :response_time,
    :duration_microseconds,
    :http_version,
    :status_code,
    :reason_phrase,
    :headers,
    :body_length
  ]

  @type t() :: %__MODULE__{
          url: String.t(),
          request_time: DateTime.t(),
          response_time: DateTime.t(),
          duration_microseconds: integer(),
          http_version: String.t(),
          status_code: integer(),
          reason_phrase: String.t(),
          headers: map(),
          body_length: integer()
        }

  @spec new(
          String.t(),
          DateTime.t(),
          DateTime.t(),
          integer(),
          String.t(),
          integer(),
          String.t(),
          map(),
          integer()
        ) :: t()
  def new(
        url,
        request_time,
        response_time,
        duration_microseconds,
        http_version,
        status_code,
        reason_phrase,
        headers,
        body_length
      ) do
    %__MODULE__{
      url: url,
      request_time: request_time,
      response_time: response_time,
      duration_microseconds: duration_microseconds,
      http_version: http_version,
      status_code: status_code,
      reason_phrase: reason_phrase,
      headers: headers,
      body_length: body_length
    }
  end
end
