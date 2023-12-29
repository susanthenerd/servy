defmodule Servy.Api.BearController do
  def index(%Servy.Conv{} = conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Jason.encode!()

    conv = Servy.Conv.put_resp_content_type(conv, "application/json")

    %Servy.Conv{conv | status: 200, resp_body: json}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created a #{type} bear named #{name}!"}
  end
end
