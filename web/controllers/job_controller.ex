defmodule Chatty.JobController do
  use Chatty.Web, :controller

  def stats(conn, _params) do
    {:ok, processed} = Exq.Api.stats(:exq_enqueuer, "processed")
    {:ok, failed} = Exq.Api.stats(:exq_enqueuer, "failed")
    {:ok, busy} = Exq.Api.busy(:exq_enqueuer)
    {:ok, scheduled} = Exq.Api.queue_size(:exq_enqueuer, :scheduled)
    {:ok, queues} = Exq.Api.queue_size(:exq_enqueuer)
    queue_sizes = for {_q, size} <- queues do
      {size, _} = Integer.parse(size)
      size
    end
    qtotal = "#{Enum.sum(queue_sizes)}"

    render(conn, :stats, stats: %{
      processed: processed,
      failed: failed,
      busy: busy,
      scheduled: scheduled,
      enqueued: qtotal
    })
  end

  def create(conn, %{"job_name" =>  job_name}) do
    {:ok, jid} = Exq.enqueue(:exq_enqueuer, "default", job_name, [])
    render(conn, :show, job: %{id: jid})
  end

end
