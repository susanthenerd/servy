defmodule Servy.Bear do
  @derive Jason.Encoder
  defstruct type: "", id: nil, name: "", hibernating: false

  def order_asc_by_name(%Servy.Bear{name: name1}, %Servy.Bear{name: name2}) do
    name1 <= name2
  end
end
