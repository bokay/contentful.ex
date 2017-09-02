defmodule Contentful.Request do
  @moduledoc """
  The Contentful.Request module wraps the external requests made.
  For now, only the get method is created, as it's the only one relevant for the
  delivery API. Every request made is logged.
  """

  require Logger

  @type method :: :put | :get | :delete
  @type error :: {:error, any}
  @type success :: {:ok, any}

  @spec request(method, String.t, map) :: error | success
  def request(:get, url, params) do
    headers = params[:headers]

    response = HTTPotion.get(url, headers: headers, timeout: 4_000)
    try do
      case JSON.decode(response.body) do
        {:ok, data} ->
          cond do
            has_error_field?(data) ->
              log(:error, :get, url, data)
              {:error, data}
            true ->
              log(:info, :get, url)
              {:ok, data}
          end
        error ->
          log(:error, :get, url, error)
          {:error, :json_decoding_error}
      end
    rescue
      error ->
        log(:error, :get, url, error)
        {:error, error}
    end
  end

  defp has_error_field?(data) do
    data["sys"]["type"] == "Error"
  end

  @spec log(atom, atom, String.t) :: atom
  defp log(:info, method, url) do
    Logger.info fn ->
      ~s( method: #{method} \n url: #{url} \n body)
    end
  end

  @spec log(atom, atom, String.t, any) :: atom
  defp log(:error, method, url, error) do
    Logger.info fn ->
      ~s( method: #{method} \n url: #{url} \n error: #{inspect error})
    end
  end
end
