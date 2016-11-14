defmodule Contentful.Delivery do
  @moduledoc """
  A HTTP client for Contentful.
  This module contains the functions to interact with Contentful's read-only
  Content Delivery API.
  """

  alias Contentful.Request

  @protocol "https"

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

    response = contentful_request(
      hostname,
      entries_url,
      access_token,
      Map.delete(params, "resolve_includes"))

    cond do
      params["resolve_includes"] == false ->
        response["items"]
      true ->
        response
        |> Contentful.IncludeResolver.resolve_entry
        |> Map.fetch!("items")
    end
  end

  def entry(hostname, space_id, access_token, entry_id, params \\ %{}) do
    entries = entries(hostname, space_id, access_token, Map.merge(params, %{'sys.id' => entry_id}))
    case entries do
      [] -> nil
      _ -> Enum.fetch!(entries, 0)
    end
  end

  def assets(hostname, space_id, access_token, params \\ %{}) do
    assets_url = "/spaces/#{space_id}/assets"

    contentful_request(
      hostname,
      assets_url,
      access_token,
      params
    )["items"]
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

    contentful_request(
      hostname,
      content_types_url,
      access_token,
      params
    )["items"]
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
    args = %{headers: client_headers(access_token),
             body: ""}

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
