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

  def run(file_name) do
    #
    case parse_update(file_name) do
      {:ok, chunks} ->
        old_size =
          get_sum()
          |> String.to_integer(16)

        expected_size = rem(get_file_size(chunks, 0) + old_size, 256)

        send_update(chunks, 0)

        if String.to_integer(get_sum(), 16) == expected_size do
          "Update Succsessful"
        else
          "Update Succsessful"
        end

      {:error, error} ->
        error <> "Can not read file."
    end
  end

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

  defp get_file_size(chunks, size) do
    if chunks != [] do
      [head | tail] = chunks
      new_size = count_chunk(head, size)

      get_file_size(tail, new_size)
    else
      size
    end
  end

  defp count_chunk(chunk, size) do
    {:ok, bytes} =
      String.trim(chunk, ":")
      |> Base.decode64(padding: false)

    # IO.puts(byte_size(bytes))
    size + byte_size(bytes)
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

  defp send_update(chunks, counter) do
    if chunks != [] do
      [head | tail] = chunks
      {:ok, response} = HTTPoison.post(@url, "CHUNK: " <> head, [], [])

      case response.body do
        "ERROR PROCESSING CONTENTS\n" ->
          if counter < @error_fault do
            send_update(chunks, counter + 1)
          else
            {:error, "ERROR PROCESSING CONTENTS\n"}
          end

        "OK\n" ->
          send_update(tail, 0)

        _ ->
          {:error, "ERROR PROCESSING CONTENTS\n"}
          "Error in connecting to server"
      end
    else
      get_sum()
    end
  end

  defp get_sum() do
    {:ok, response} = HTTPoison.post(@url, "CHECKSUM", [], [])
    [_, sum] = String.split(response.body)
    String.slice(sum, 2..10)
  end
end
