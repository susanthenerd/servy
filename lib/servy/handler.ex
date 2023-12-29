defmodule Servy.Handler do
  require Logger
  alias Servy.Conv
  alias Servy.BearController

  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  @moduledoc """
  Handles HTTP requests.
  """

  @pages_path Path.expand("pages", File.cwd!())

  @doc """
  Transforms the request into a response.
  """

  def handle(request) do
    request
    |> parse()
    |> Servy.Plugins.rewrite_path()
    |> Servy.Plugins.log()
    |> route
    |> Servy.Plugins.track()
    |> Conv.put_content_length()
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %Conv{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    BearController.newBearPage(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)

    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> name} = conv) do
    @pages_path
    |> Path.join("#{name}.md")
    |> File.read()
    |> handle_file(conv)
    |> markdown_to_html
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    sensors = Servy.SensorServer.get_sensor_data()

    html = Servy.SensorsView.sensors(sensors.snapshots, sensors.location)

    %{conv | status: 200, resp_body: html}
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    Servy.PledgeController.new(conv)
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counts = Servy.FourOhFourCounter.get_counts()

    %{conv | status: 200, resp_body: inspect(counts)}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{Conv.format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  def markdown_to_html(%Conv{status: 200} = conv) do
    %{conv | resp_body: Earmark.as_html!(conv.resp_body)}
  end

  def markdown_to_html(%Conv{} = conv), do: conv
end
