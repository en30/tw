defmodule Tw.V1_1.Media do
  @moduledoc """
  Media data structure and related functions.

  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  import Tw.V1_1.Schema, only: :macros

  alias Tw.V1_1.Client

  defobject("priv/schema/model/media.json")

  @type upload_param ::
          {:media_category, binary()}
          | {:additional_owners, list(pos_integer())}

  @type upload_ok_result :: %{
          media_id: pos_integer(),
          media_id_string: binary(),
          expires_after_secs: pos_integer()
        }

  @type upload_error_result :: %{
          media_id: pos_integer(),
          media_id_string: binary(),
          processing_info: %{
            state: binary(),
            error: %{
              code: integer(),
              name: binary(),
              message: binary()
            }
          }
        }

  @chunk_size 1024 * 1024

  @doc """
  Upload an image or video to Twitter by senqunce of requests to `POST media/upload` and `GET media/upload`.
  If you want to use more low-level API, use `upload_command/3` instead.

  ## Examples
      iex> {:ok, res} = Tw.V1_1.Media.upload(client, "/tmp/abc.png")
      iex> Tw.V1_1.Tweet.create(client, status: "Tweets with a image", media_ids: [res.media_id])
      {:ok, %Tw.V1_1.Tweet{}}

      iex> {:ok, res} = Tw.V1_1.Media.upload(client, %{data: png_binary, media_type: "image/png"})
      iex> Tw.V1_1.Tweet.create(client, status: "Tweets with a image", media_ids: [res.media_id])
      {:ok, %Tw.V1_1.Tweet{}}

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/overview) for details.
  """
  @spec upload(
          Client.t(),
          Path.t()
          | %{device: IO.device(), media_type: binary(), total_bytes: pos_integer()}
          | %{data: iodata(), media_type: binary()},
          [upload_param()]
        ) ::
          {:ok, upload_ok_result()}
          | {:error, Tw.V1_1.TwitterAPIError.t() | Jason.DecodeError.t() | upload_error_result()}
  def upload(client, path_or_device_or_binary, opts \\ [])

  def upload(client, path, opts) when is_binary(path) do
    with {:ok, stat} <- File.stat(path),
         {:ok, media_type} <- infer_media_type(path),
         {:ok, device} <- File.open(path, [:binary, :read]) do
      try do
        upload(client, %{device: device, media_type: media_type, total_bytes: stat.size}, opts)
      after
        File.close(device)
      end
    else
      error -> error
    end
  end

  def upload(client, %{device: device, media_type: media_type, total_bytes: total_bytes}, opts) do
    opts =
      opts
      |> Keyword.merge(media_type: media_type, total_bytes: total_bytes)
      |> Keyword.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, IO.binstream(device, @chunk_size), opts)
  end

  def upload(client, %{data: data, media_type: media_type}, opts) do
    opts =
      opts
      |> Keyword.merge(media_type: media_type, total_bytes: IO.iodata_length(data))
      |> Keyword.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, data |> IO.iodata_to_binary() |> chunks(), opts)
  end

  defp upload_sequence(client, chunks, init_opts) do
    with {:ok, init_result} <- initialize_upload(client, init_opts),
         :ok <- upload_chunks(client, chunks, media_id: init_result.media_id),
         {:ok, finalize_result} <- finalize_upload(client, media_id: init_result.media_id),
         {:ok, res} <- wait_for_processing(client, finalize_result) do
      {:ok, res}
    else
      error -> error
    end
  end

  defp chunks(<<chunk::binary-size(@chunk_size), rest::binary>>), do: [chunk | chunks(rest)]
  defp chunks(rest), do: [rest]

  defp initialize_upload(client, opts) do
    upload_command(client, :post, opts |> Keyword.put(:command, "INIT"))
  end

  defp upload_chunks(client, chunks, media_id: media_id) do
    chunks
    |> Stream.with_index()
    |> Task.async_stream(fn {bin, i} ->
      upload_append(client, media_id: media_id, media: bin, segment_index: i)
    end)
    |> Enum.filter(&match?({:error, _}, &1))
    |> case do
      [] -> :ok
      [error | _] -> error
    end
  end

  defp upload_append(client, opts) do
    upload_command(client, :post, opts |> Keyword.put(:command, "APPEND"))
  end

  defp finalize_upload(client, opts) do
    upload_command(client, :post, opts |> Keyword.put(:command, "FINALIZE"))
  end

  defp wait_for_processing(client, finalize_result)

  defp wait_for_processing(_client, %{processing_info: %{state: "failed"}} = res) do
    {:error, res}
  end

  defp wait_for_processing(_client, %{processing_info: %{state: "succeeded"}} = res) do
    {:ok, res}
  end

  defp wait_for_processing(client, %{processing_info: %{state: state} = processing_info} = res)
       when state in ["pending", "in_progress"] do
    Process.sleep(:timer.seconds(processing_info.check_after_secs))

    case upload_command(client, :get, command: "STATUS", media_id: res.media_id) do
      {:ok, res} -> wait_for_processing(client, res)
      error -> error
    end
  end

  defp wait_for_processing(_client, res), do: {:ok, res}

  @spec upload_command(Client.t(), :get | :post, keyword()) :: {:ok, %{atom => term}} | {:error, term}
  def upload_command(client, method, opts) do
    with {:ok, resp} <- Client.request(client, method, "/media/upload.json", opts),
         {:ok, res} <- Jason.decode(resp.body, keys: :atoms) do
      {:ok, res}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  # https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/uploading-media/media-best-practices
  defp infer_media_type(path) do
    case Path.extname(path) do
      ".mp4" ->
        {:ok, "video/mp4"}

      ".mov" ->
        {:ok, "video/quicktime"}

      ".png" ->
        {:ok, "image/png"}

      ".webp" ->
        {:ok, "image/webp"}

      ".gif" ->
        {:ok, "image/gif"}

      ext when ext in [".jpg", ".jpeg", ".jfif", ".pjpeg", "pjp"] ->
        {:ok, "image/jpeg"}

      name ->
        {:error, "Could not infer media type from the extension `#{name}`"}
    end
  end

  defp category_from_type("image/gif"), do: "tweet_gif"
  defp category_from_type("image/" <> _), do: "tweet_image"
  defp category_from_type("video/" <> _), do: "tweet_video"
end
