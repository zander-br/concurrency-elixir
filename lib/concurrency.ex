defmodule Concurrency do
  alias Concurrency.Services.{BTC, Converter, ETH, LTC, USD}
  alias Concurrency.Workflow

  def execute() do
    price_services = [BTC, ETH, LTC, USD]

    %{}
    |> Workflow.create()
    |> Workflow.step_async(price_services)
    |> Workflow.step([Converter])
    |> Workflow.finish(&formatter_result/1)
  end

  defp formatter_result(result), do: Map.delete(result, :usd)
end
