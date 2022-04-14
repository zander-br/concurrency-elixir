defmodule Concurrency.Services.USD do
  alias Concurrency.Services.HTTPClient

  def run(_params) do
    price =
      "https://economia.awesomeapi.com.br/last/USD-BRL"
      |> HTTPClient.get_json!()
      |> Map.get("USDBRL")
      |> Map.get("ask")
      |> String.to_float()

    {:ok, %{usd: price}}
  end
end
