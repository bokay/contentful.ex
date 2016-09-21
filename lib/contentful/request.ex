defmodule Contentful.Request do
  require Logger

  @type method :: :put | :get | :delete
  @type error :: {:error, String.t}
  @type success :: {:body, String.t} | {:json, String.t}

  @spec request(method, String.t, map) :: error | success
  def request(method, url, params) do
    case :hackney.request(method, url, params[:headers], params[:payload], params[:options]) do
      {:ok, _status_code, _headers, client_ref} ->
        case :hackney.body(client_ref) do
          {:ok, body} -> case JSON.decode(body) do
                           {:ok, data} ->
                             log(:info, method, url)
                             data
                           _ ->
                             log(:info, method, url)
                             body
                         end
          {:error, error} -> log(:error, method, url, error)
        end
      error ->
        case error do
          {:ok, data} ->
            log(:error, method, url, data)
            {:error, data }
          _ ->
            log(:error, method, url, error)
            {:error, error }
        end
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
