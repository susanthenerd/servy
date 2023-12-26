defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  import Servy.FileHandler, only: [handle_file: 2]

  @pages_path Path.expand("pages", File.cwd!())

  def bear_item(%Servy.Bear{name: name, type: type}) do
    "<li>#{name} - #{type}</li>"
  end

  def index(conv) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly/1)
      |> Enum.sort(&Bear.order_asc_by_name/2)
      |> Enum.map(&bear_item/1)
      |> Enum.join()

    %Conv{conv | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %Conv{conv | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.id}</h1>"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end

  def newBearPage(conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def delete(conv) do
    %Conv{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end
end
