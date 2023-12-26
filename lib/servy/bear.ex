defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_grizzly(%Servy.Bear{type: type}) do
    type == "Grizzly"
  end

  def order_asc_by_name(%Servy.Bear{name: name1}, %Servy.Bear{name: name2}) do
    name1 <= name2
  end

  def bear_item(%Servy.Bear{name: name, type: type}) do
    "<li>#{name} - #{type}</li>"
  end
end
