defmodule App do
  @moduledoc """
  Documentation for App.
  """

  @doc """
  parse update.

  ## Examples

      iex> App.parse_update(file_name)
      [file_line1,file_line2,est]

  """
  def parse_update(file_name) do
    case File.read("../" <> file_name) do
      {:ok, content} ->
        content
        |> String.split("\r\n", trim: true)

      {:error, error} ->
        error <>
          "Please make sure the file is in the same file as the application and that you are giving the file's name"
    end
  end
end
