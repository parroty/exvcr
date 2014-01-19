defrecord ExVCR.Record, options: nil, responses: nil
defrecord ExVCR.Request, url: nil, headers: [], method: nil, body: nil, options: []
defrecord ExVCR.Response, status_code: nil, headers: [], body: nil
defrecord ExVCR.Checker.Results, dirs: nil, files: []
