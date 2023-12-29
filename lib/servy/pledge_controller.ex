defmodule Servy.PledgeController do
  alias Servy.PledgeView
  alias Servy.PledgeServer

  @doc """
  Creates a new pledge
  """
  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it

    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))

    html =
      PledgeServer.recent_pledges()
      |> PledgeView.recent()

    %{conv | status: 201, resp_body: html}
  end

  @doc """
  Returns the recent pledges page
  """
  def index(conv) do
    # Gets the recent pledges from the cache
    html =
      PledgeServer.recent_pledges()
      |> PledgeView.recent()

    %{conv | status: 200, resp_body: html}
  end

  @doc """
  Returns the new pledge page
  """
  def new(conv) do
    html = PledgeView.new()

    %{conv | status: 200, resp_body: html}
  end
end
