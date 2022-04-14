defmodule Concurrency.Services.HTTPClient do
  def get_json!(url) do
    HTTPoison.get!(url)
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
