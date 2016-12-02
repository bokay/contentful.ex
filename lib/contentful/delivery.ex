defmodule Contentful.Delivery do
  @moduledoc """
  This module contains the functions to interact with Contentful's read-only
  Content Delivery API.
  """

  alias Contentful.Request

  @type error :: {:error, String.t}
  @type success :: {:ok, String.t}

  @protocol "https"


  @spec space(String.t, String.t, String.t) :: error | success
  def space(hostname, space_id, access_token) do
    space_url = "/spaces/#{space_id}"

    contentful_request(
      hostname,
      space_url,
      access_token
    )
  end

  def entries(hostname, space_id, access_token, params \\ %{}) do
    entries_url = "/spaces/#{space_id}/entries"

    case contentful_request(
          hostname,
          entries_url,
          access_token,
          Map.delete(params, "resolve_includes")) do
      {:ok, response} ->
        cond do
          params["resolve_includes"] == false ->
            {:ok, response["items"]}
          true ->
            item =
              response
              |> Contentful.IncludeResolver.resolve_entry
              |> Map.fetch!("items")
            {:ok, item}
        end
      error_tuple -> error_tuple
    end
  end

  def entry(hostname, space_id, access_token, entry_id, params \\ %{}) do
    case entries(
          hostname,
          space_id,
          access_token,
          Map.merge(params, %{'sys.id' => entry_id})) do
      {:ok, entries} ->
        case entries do
          [] -> {:error, nil}
          _  -> {:ok, Enum.fetch!(entries, 0)}
      end
    end
  end

  def assets(hostname, space_id, access_token, params \\ %{}) do
    assets_url = "/spaces/#{space_id}/assets"

    case contentful_request(
          hostname,
          assets_url,
          access_token,
          params) do
      {:ok, response} -> {:ok, response["items"]}
      error_tuple     -> error_tuple
    end
  end

  def asset(hostname, space_id, access_token, asset_id, params \\ %{}) do
    asset_url = "/spaces/#{space_id}/assets/#{asset_id}"

    contentful_request(
      hostname,
      asset_url,
      access_token,
      params
    )
  end

  def content_types(hostname, space_id, access_token, params \\ %{}) do
    content_types_url = "/spaces/#{space_id}/content_types"

    case contentful_request(
          hostname,
          content_types_url,
          access_token,
          params) do
      {:ok, response} -> {:ok, response["items"]}
      error_tuple     -> error_tuple
    end
  end

  def content_type(hostname, space_id, access_token, content_type_id, params \\ %{}) do
    content_type_url = "/spaces/#{space_id}/content_types/#{content_type_id}"

    contentful_request(
      hostname,
      content_type_url,
      access_token,
      params
    )
  end

  defp contentful_request(hostname, uri, access_token, params \\ %{}) do
    args = %{headers: client_headers(access_token), body: ""}

    final_url = format_path(path: uri, params: params)
    url = "#{@protocol}://#{hostname}#{final_url}"

    Request.request(:get, url, args)
  end

  defp client_headers(access_token) do
    [
      {"authorization", "Bearer #{access_token}"},
      {"Accept", "application/json"},
      {"User-Agent", "Contentful-Elixir"}
    ]
  end

  defp format_path(path: path, params: params) do
    if Enum.any?(params) do
      query = params
      |> Enum.reduce("", fn ({k, v}, acc) -> acc <> "#{k}=#{v}&" end)
      |> String.rstrip(?&)
      "#{path}/?#{query}"
    else
      path
    end
  end
end
