defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv

  @moduledoc """
  A couple of plugins
  """

  def log(%Conv{} = conv) do
    if Mix.env() == :env do
      IO.inspect(conv)
    end

    conv
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)

    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  @doc """
  Logs 404 requests.
  """
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env() != :test do
      IO.puts("Warning: #{path} is on the loose!")
      Servy.FourOhFourCounter.bump_count(path)
    end

    conv
  end

  def track(%Conv{} = conv), do: conv
end
