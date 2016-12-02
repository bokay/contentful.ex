defmodule Contentful.IncludeResolverTest do
  use ExUnit.Case
  alias Contentful.Delivery
  alias Contentful.IncludeResolver
  use ExVCR.Mock

  @access_token  "ACCESS_TOKEN"
  @space_id      "osfkcaa4fuwa"
  @hostname      "cdn.contentful.com"

  setup do
    ExVCR.Config.filter_sensitive_data("Bearer .+", "ACCESS_TOKEN")
    :ok
  end

  @tag timeout: 10000
  test "entries" do
    use_cassette "resolve_entries" do
      {:ok, entries} =
        Delivery.entries(@hostname, @space_id, @access_token, %{"resolve_includes" => true})

      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    use_cassette "single_entry_with_includes2" do
    {:ok, entries} = Delivery.entries(@hostname, @space_id, @access_token, %{
          "content_type" => "380684",
          "fields.slug"  => "evaluation-of-electronic-medical-record-vital-sign-data-versus-a-commercially-available-acuity-score-in-predicting-need-for-critical-intervention-at-a-tertiary-children-s-hospital",
          "include"      => 10,
          "resolve_includes" => true})

      assert is_list(entries)
    end
  end


  @tag timeout: 10000
  test "entry" do
    use_cassette "resolve_entry" do
      {:ok, entry} = Delivery.entry(
        @hostname,
        @space_id,
        @access_token,
        "2981282",
        %{"resolve_includes" => true})

      assert is_map(entry)
    end
  end
end
