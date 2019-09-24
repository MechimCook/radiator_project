defmodule App do
  @moduledoc """
  Documentation for App.
  When run this application will read a hex file from within the same dirrectory as the app,
  given the file file_name. The program will parse the file line by line then format each
  element to be less than 20 bytes. It will then upload each new element retrying up to 10 times for each element.
  After the last element is uploaded it will check the checksum to check the upload and respond if successful or not.

  """

  @doc """


  ## Examples

      iex> App.run(file_name)
      "Update Succsessful"

  """

  @url "http://localhost:3000"
  @error_fault 10

  defp parse_update(file_name) do
    case File.read("../" <> file_name) do
      {:ok, chunks} ->
        {formated_chunks} =
          chunks
          |> String.split("\r\n", trim: true)
          |> format_chunks(0)

        {:ok, formated_chunks}

      {:error, error} ->
        IO.puts(
          IO.inspect(error) <>
            "Please make sure the file is in the same file as the application and that you are giving the file's name"
        )

        {:error, error}
    end
  end

  defp format_chunks(chunks, counter) do
    {chunk, _} = List.pop_at(chunks, counter)

    case inspect_chunk(chunk) do
      {:ok} ->
        if counter <= length(chunks) - 2 do
          format_chunks(chunks, counter + 1)
        else
          {chunks}
        end

      {bytes} ->
        # split the first 20 bytes out, convert the 2 bytes back to hex, then insert them back into the list of chunks
        {byte1, byte2} = Binary.split_at(bytes, 20)
        chunk1 = ":" <> Base.encode64(byte1, padding: false)
        chunk2 = ":" <> Base.encode64(byte2, padding: false)

        new_chunks =
          List.delete_at(chunks, counter)
          |> List.insert_at(counter, [chunk1, chunk2])
          |> List.flatten()

        if counter <= length(new_chunks) - 2 do
          format_chunks(new_chunks, counter + 1)
        else
          {new_chunks}
        end
    end
  end

  defp inspect_chunk(chunk) do
    {:ok, bytes} =
      String.trim(chunk, ":")
      |> Base.decode64(padding: false)

    if byte_size(bytes) > 20 do
      {bytes}
    else
      {:ok}
    end
  end
end
