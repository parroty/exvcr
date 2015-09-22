defmodule ExVCR.Record do
  defstruct options: nil, responses: nil
end

defmodule ExVCR.Request do
  defstruct url: nil, headers: [], method: nil, body: nil, options: [], request_body: ""
end

defmodule ExVCR.Response do
  defstruct type: "ok", status_code: nil, headers: [], body: nil
end

defmodule ExVCR.Checker.Results do
  defstruct dirs: nil, files: []
end
defmodule ExVCR.Checker.Counts do
  defstruct server: 0, cache: 0
end
