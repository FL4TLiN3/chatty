defmodule Chatty.JobView do
  use Chatty.Web, :view

  def render("stats.json", %{stats: stats}) do
    %{
      data: %{
        processed: stats.processed,
        failed: stats.failed,
        busy: stats.busy,
        scheduled: stats.scheduled,
        enqueued: stats.enqueued
      }
    }
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, Chatty.JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    %{id: job.id}
  end
end
