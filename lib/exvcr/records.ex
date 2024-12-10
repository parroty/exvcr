defmodule ExVCR.Record do
  @moduledoc false
  defstruct options: nil, responses: nil
end

defmodule ExVCR.Request do
  @moduledoc false
  @derive Jason.Encoder
  defstruct url: nil, headers: [], method: nil, body: nil, options: [], request_body: ""
end

defmodule ExVCR.Response do
  @moduledoc false
  @derive Jason.Encoder
  defstruct type: "ok", status_code: nil, headers: [], body: nil, binary: false
end

defmodule ExVCR.Checker.Results do
  @moduledoc false
  defstruct dirs: nil, files: []
end

defmodule ExVCR.Checker.Counts do
  @moduledoc false
  defstruct server: 0, cache: 0
end
