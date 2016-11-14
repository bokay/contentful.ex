defmodule Contentful.Request do
  require Logger

  @type method :: :put | :get | :delete
  @type error :: {:error, String.t}
  @type success :: {:body, String.t} | {:json, String.t}

  @spec request(method, String.t, map) :: error | success
  def request(:get, url, params) do
    headers = params[:headers]
    payload = params[:payload]

    response = HTTPotion.get(url, headers: headers, timeout: 4_000)
    try do
      case JSON.decode(response.body) do
        {:ok, data} ->
          log(:info, :get, url)
          data
        _ ->
          log(:info, :get, url)
      end
    rescue
      error -> log(:error, :get, url, error)
    end
  end

  @spec log(atom, atom, String.t) :: atom
  defp log(:info, method, url) do
    _ = Logger.info fn ->
      ~s( method: #{method} \n url: #{url} \n body); end
    :ok
  end
  @spec log(atom, atom, String.t, String.t) :: atom
  defp log(:info, method, url, data) do
    _ = Logger.info fn ->
      ~s( method: #{method} \n url: #{url} \n body: #{inspect data}); end
    :ok
  end
  defp log(:error, method, url, error) do
    _ = Logger.info fn ->
      ~s( method: #{method} \n url: #{url} \n error: #{inspect error});
    end
    :ok
  end
end
