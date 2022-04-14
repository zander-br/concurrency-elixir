defmodule Concurrency.Services.LTC do
  alias Concurrency.Services.HTTPClient

  @coinbase_base_url "https://api.pro.coinbase.com"

  def ticker_url(product_id), do: "#{@coinbase_base_url}/products/#{product_id}/ticker"

  def run(_params) do
    price =
      "LTC-USD"
      |> ticker_url()
      |> HTTPClient.get_json!()
      |> Map.get("price")
      |> String.to_float()

    {:ok, %{ltc: price}}
  end
end
