defmodule Concurrency.Services.Converter do
  def run(%{usd: usd} = params) do
    result =
      params
      |> Map.delete(:usd)
      |> Enum.map(fn {key, value} -> {key, Float.round(value * usd, 4)} end)
      |> Enum.into(%{})

    {:ok, result}
  end
end
