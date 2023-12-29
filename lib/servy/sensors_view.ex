defmodule Servy.SensorsView do
  @templates_path Path.expand("templates", File.cwd!())

  require EEx

  EEx.function_from_file(:def, :sensors, Path.join(@templates_path, "sensors.eex"), [
    :snapshots,
    :location
  ])
end
