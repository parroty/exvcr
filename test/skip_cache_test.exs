defmodule ExVCR.SkipCacheTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc
  alias ExVCR.Recorder
  alias ExVCR.Mock
  alias ExVCR.Actor.Responses

  test "skips cache when the skip_cache option is passed" do
    recorder = Recorder.start([skip_cache: true, fixture: "stubbed_request", adapter: ExVCR.Adapter.Httpc])
    Mock.mock_methods(recorder, ExVCR.Adapter.Httpc)

    [first_body, second_body] = make_random_requests()

    responses = Responses.get(recorder.responses)

    assert first_body != second_body
    assert Enum.count(responses) == 2
  end

  test "relies on cache during record when skip_cache is not passed" do
    recorder = Recorder.start([fixture: "stubbed_request", adapter: ExVCR.Adapter.Httpc])
    Mock.mock_methods(recorder, ExVCR.Adapter.Httpc)

    [first_body, second_body] = make_random_requests()

    responses = Responses.get(recorder.responses)

    assert first_body == second_body
    assert Enum.count(responses) == 1
  end

  test "uses the correct responses when recorded with skip_cache enabled" do
    use_cassette "skips_cache" do
      [first_body, second_body] = make_random_requests()
      assert first_body != second_body
    end
  end

  defp make_random_requests do
    random_url = 'https://www.random.org/integers/?num=1&min=1&max=10000&col=1&base=10&format=plain&rnd=new'
    {:ok, {_res, _headers, first_body}} = :httpc.request(random_url)
    {:ok, {_res, _headers, second_body}} = :httpc.request(random_url)

    [first_body, second_body]
  end
end
