defmodule LLM.Client do
  @moduledoc """
  Thin wrapper for calling LLMs via OpenAI compatible API
  """

  @base_url "http://localhost:11434/v1/chat/completions"
  @model "codestral:22b"
  @correction_schema %{
    type: "object",
    required: ["corrected_text"],
    properties: %{
      corrected_text: %{type: "string"}
    },
    additionalProperties: false
  }

  @doc """
  calls the LLM chat api with the prompt and returns the response
  hardcoded to just call local ollama for now. Configuration to come later
  """
  def call(prompt) do
    req_options =
      Application.get_env(:shinar, :llm, [])
      |> Keyword.get(:req_options, [])

    # call the local llm
    response =
      Req.post(
        @base_url,
        Keyword.merge(req_options,
          json: %{
            model: @model,
            messages: [%{"role" => "user", "content" => prompt}],
            temperature: 0,
            response_format: %{
              type: "json_schema",
              json_schema: %{name: "correction", strict: true, schema: @correction_schema}
            }
          },
          receive_timeout: 180_000
        )
      )

    case response do
      {:ok,
       %Req.Response{
         status: 200,
         body: %{"choices" => [%{"message" => %{"content" => content}} | _]}
       }} ->
        case Jason.decode(content) do
          {:ok, parsed_content} -> {:ok, parsed_content}
          {:error, reason} -> {:error, {:invalid_json, reason}}
        end

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, %Req.TransportError{} = error} ->
        {:error, error}
    end
  end
end
