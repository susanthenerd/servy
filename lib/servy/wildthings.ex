defmodule Servy.Wildthings do
  alias Servy.Bear

  @db_path Path.expand("db", File.cwd!())

  # List all bears from the JSON file
  def list_bears do
    @db_path
    |> Path.join("bears.json")
    |> read_json
    |> parse_json
  end

  # Read the contents of the JSON file
  defp read_json(source) do
    case File.read(source) do
      {:ok, contents} ->
        contents

      {:error, reason} ->
        IO.inspect("Error reading #{source}: #{reason}")
        "[]"
    end
  end

  # Parse the JSON contents into a list of maps (bears)
  defp parse_json(contents) do
    case Jason.decode(contents) do
      {:ok, data} ->
        Enum.map(data["bears"], &parse_bear/1)

      {:error, _reason} ->
        []
    end
  end

  defp parse_bear(%{} = bear) do
    new_bear = %Bear{
      id: bear["id"],
      name: bear["name"],
      type: bear["type"]
    }

    if(is_nil(bear["hibernating"])) do
      %Bear{new_bear | hibernating: false}
    else
      %Bear{new_bear | hibernating: bear["hibernating"]}
    end
  end

  # Retrieve a single bear by ID
  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn b -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end
end
