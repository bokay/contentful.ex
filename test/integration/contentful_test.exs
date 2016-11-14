defmodule Contentful.DeliveryTest do
  use ExUnit.Case
  alias Contentful.Delivery
  use ExVCR.Mock

  @access_token  "ACCESS_TOKEN"
  @space_id      "if4k9hkjacuz"
  @hostname      "cdn.contentful.com"

  setup do
    ExVCR.Config.filter_sensitive_data("Bearer .+", "ACCESS_TOKEN")
    :ok
  end

  @tag timeout: 10000
  test "entries" do
    use_cassette "entries" do
      entries = Delivery.entries(@hostname, @space_id, @access_token)
      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    use_cassette "single_entry_with_includes" do
      space_id = "if4k9hkjacuz"
      entries = Delivery.entries(@hostname, space_id, @access_token, %{
            "content_type" => "6pFEhaSgDKimyOCE0AKuqe",
            "fields.slug" => "test-page",
            "include" => "10"}
      )
      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "entry" do
    use_cassette "entry" do
      entry = Delivery.entry(@hostname, @space_id, @access_token, "53l06m2nzOMOQ6YGcWgmcw")

      assert is_map(entry["fields"])
    end
  end

  test "content_types" do
    use_cassette "content_types" do
      first_content_type = Delivery.content_types(@hostname, @space_id, @access_token)
      |> List.first

      assert is_list(first_content_type["fields"])
    end
  end

  test "content_type" do
    use_cassette "content_type" do
      content_type = Delivery.content_type(@hostname, @space_id, @access_token, "7hyub4rrpKy6AecWgUSOUq")

      assert is_list(content_type["fields"])
    end
  end

  test "assets" do
    use_cassette "assets" do
      first_asset = Delivery.assets(@hostname, @space_id, @access_token)
      |> List.first

      assert is_map(first_asset["fields"])
    end
  end

  test "asset" do
    use_cassette "asset" do
      asset = Delivery.asset(@hostname, @space_id, @access_token, "2BppH8PireiCaQIUqkOuge")
      fields = asset["fields"]

      assert is_map(fields)
    end
  end

  test "space" do
    use_cassette "space" do
      space = Delivery.space(@hostname, @space_id, @access_token)
      locales = space["locales"]
      |> List.first

      assert locales["code"] == "en-US"
    end
  end
end
