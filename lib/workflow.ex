defmodule Concurrency.Workflow do
  def create(params), do: {:ok, params}

  def step({:ok, %{} = params}, [service | services]) do
    case service.run(params) do
      {:ok, result} -> step({:ok, Map.merge(params, result)}, services)
      {:error, reason} -> {:error, reason}
    end
  end

  def step({:ok, %{} = result}, []), do: {:ok, result}
  def step({:error, _reason} = error, _services), do: error

  def step_async({:ok, %{} = params}, services) do
    services
    |> Enum.map(fn service -> spawn_service(%{params: params, service: service}, self()) end)
    |> Enum.map(&await/1)
    |> process_results(params)
  end

  def finish({:ok, result}, parser), do: {:ok, parser.(result)}
  def finish({:error, _reason} = error, _parser), do: error

  defp spawn_service(%{params: params, service: service}, destination_pid) do
    spawn(fn ->
      case service.run(params) do
        {:ok, result} -> send(destination_pid, {self(), {:ok, result}})
        {:error, reason} -> send(destination_pid, {self(), {:error, reason}})
      end
    end)
  end

  defp await(pid) do
    receive do
      {^pid, result} -> result
    end
  end

  defp process_results(results, params) do
    errors = Enum.filter(results, &has_error?/1)

    case Enum.empty?(errors) do
      true -> process_success(results, params)
      false -> process_error(errors)
    end
  end

  defp has_error?(result) do
    case result do
      {:ok, _} -> false
      {:error, _} -> true
    end
  end

  defp process_error(errors) do
    reasons = Enum.map(errors, fn {:error, reason} -> reason end)
    {:error, reasons}
  end

  defp process_success(results, params) do
    result =
      results
      |> Enum.map(fn {:ok, result} -> result end)
      |> Enum.reduce(&Map.merge/2)
      |> Map.merge(params)

    {:ok, result}
  end
end
