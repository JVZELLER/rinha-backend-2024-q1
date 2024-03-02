defmodule RinhaBackend.PromExDomainMetrics do
  use PromEx.Plugin

  @impl true
  def event_metrics(keyword) do
    IO.inspect(keyword)

    Event.build(
      :phoenix_http_event_metrics,
      [
        # Capture request duration information
        distribution(~w(rinha_backend domain execution total_time)a,
          # event_name: ~w(rinha_backend domain execution)a,
          # measurement: :total_time,
          description: "The total time execution spent in domain functions.",
          tags: [:client_id, :name],
          reporter_options: [
            buckets: [1, 10, 50, 100, 250, 500, 1_000, 2_000, 3_000, 5_000, 8_000, 15_000]
          ],
          unit: {:native, :millisecond}
        )
      ]
    )
  end
end
