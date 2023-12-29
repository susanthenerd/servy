defmodule Servy.PledgeView do
  require EEx

  @templates_path Path.expand("templates", File.cwd!())

  EEx.function_from_file(:def, :new, Path.join(@templates_path, "new_pledge.eex"), [])

  EEx.function_from_file(:def, :recent, Path.join(@templates_path, "recent_pledges.eex"), [
    :pledges
  ])
end
