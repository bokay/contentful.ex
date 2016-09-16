defmodule Contentful.IncludeResolverTest do
  use ExUnit.Case
  alias Contentful.Delivery
  alias Contentful.IncludeResolver
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @access_token  "ffa20a81e0d56de9150d6b9b7a38e07e0fb4df78500d7418b23f8919ba2f66cc"
  @space_id      "z3aswf9egfi8"

  setup_all do
    HTTPoison.start
  end

  @tag timeout: 10000
  test "entries" do
    use_cassette "entries" do
      entries =
        Delivery.entries(@hostname, @space_id, @access_token, %{"resolve_includes" => true})

      assert is_list(entries)
    end
  end

  @tag timeout: 10000
  test "search entry with includes" do
    # use_cassette "single_entry_with_includes" do
    space_id = "osfkcaa4fuwa"
      entries = Delivery.entries(@hostname, space_id, @access_token, %{
          "content_type" => "380684",
          "fields.slug"  => "evaluation-of-electronic-medical-record-vital-sign-data-versus-a-commercially-available-acuity-score-in-predicting-need-for-critical-intervention-at-a-tertiary-children-s-hospital",
          "include"      => 10,
          "resolve_includes" => true})

      assert is_list(entries)
    # end
  end


  @tag timeout: 10000
  test "entry" do
    use_cassette "entry" do
      entry = Delivery.entry(@hostname,
        @space_id,
        @access_token,
        "5JQ715oDQW68k8EiEuKOk8",
        %{"resolve_includes" => true})

      assert is_map(entry)
    end
  end
end
