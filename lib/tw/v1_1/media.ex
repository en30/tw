defmodule Tw.V1_1.Media do
  @moduledoc """
  Media data structure and related functions.

  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.Sizes
  alias Tw.V1_1.User

  @enforce_keys [
    :display_url,
    :expanded_url,
    :id,
    :id_str,
    :indices,
    :media_url,
    :media_url_https,
    :sizes,
    :source_status_id,
    :source_status_id_str,
    :type,
    :url
  ]
  defstruct([
    :display_url,
    :expanded_url,
    :id,
    :id_str,
    :indices,
    :media_url,
    :media_url_https,
    :sizes,
    :source_status_id,
    :source_status_id_str,
    :type,
    :url
  ])

  @typedoc """
  > | field | description |
  > | - | - |
  > | `display_url` | URL of the media to display to clients. Example: `\"pic.twitter.com/rJC5Pxsu\" `.  |
  > | `expanded_url` | An expanded version of display_url. Links to the media display page. Example: `\"http://twitter.com/yunorno/status/114080493036773378/photo/1\" `.  |
  > | `id` | ID of the media expressed as a 64-bit integer. Example: `114080493040967680 `.  |
  > | `id_str` | ID of the media expressed as a string. Example: `\"114080493040967680\" `.  |
  > | `indices` | An array of integers indicating the offsets within the Tweet text where the URL begins and ends. The first integer represents the location of the first character of the URL in the Tweet text. The second integer represents the location of the first non-URL character occurring after the URL (or the end of the string if the URL is the last part of the Tweet text). Example: `[15,35] `.  |
  > | `media_url` | An http:// URL pointing directly to the uploaded media file. Example: `\"http://pbs.twimg.com/media/DOhM30VVwAEpIHq.jpg\" For media in direct messages, media_url is the same https URL as media_url_https and must be accessed by signing a request with the user’s access token using OAuth 1.0A.It is not possible to access images via an authenticated twitter.com session. Please visit this page to learn how to account for these recent change. You cannot directly embed these images in a web page.See Photo Media URL formatting for how to format a photo's URL, such as media_url_https, based on the available sizes.`.  |
  > | `media_url_https` | An https:// URL pointing directly to the uploaded media file, for embedding on https pages. Example: `\"https://p.twimg.com/AZVLmp-CIAAbkyy.jpg\" For media in direct messages, media_url_https must be accessed by signing a request with the user’s access token using OAuth 1.0A.It is not possible to access images via an authenticated twitter.com session. Please visit this page to learn how to account for these recent change. You cannot directly embed these images in a web page.See Photo Media URL formatting for how to format a photo's URL, such as media_url_https, based on the available sizes.`.  |
  > | `sizes` | An object showing available sizes for the media file.  |
  > | `source_status_id` | Nullable. For Tweets containing media that was originally associated with a different tweet, this ID points to the original Tweet. Example: `205282515685081088 `.  |
  > | `source_status_id_str` | Nullable. For Tweets containing media that was originally associated with a different tweet, this string-based ID points to the original Tweet. Example: `\"205282515685081088\" `.  |
  > | `type` | Type of uploaded media. Possible types include photo, video, and animated_gif. Example: `\"photo\" `.  |
  > | `url` | Wrapped URL for the media link. This corresponds with the URL embedded directly into the raw Tweet text, and the values for the indices parameter. Example: `\"http://t.co/rJC5Pxsu\" `.  |
  >
  """
  @type t :: %__MODULE__{
          display_url: binary,
          expanded_url: binary,
          id: integer,
          id_str: binary,
          indices: list(integer),
          media_url: binary,
          media_url_https: binary,
          sizes: Sizes.t(),
          source_status_id: integer | nil,
          source_status_id_str: integer | nil,
          type: binary,
          url: binary
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:sizes, &Sizes.decode!/1)

    struct(__MODULE__, json)
  end

  @type upload_params ::
          %{path: Path.t(), media_category: binary(), additional_owners: list(pos_integer())}
          | %{
              device: IO.device(),
              media_type: binary(),
              total_bytes: pos_integer(),
              media_category: binary(),
              additional_owners: list(pos_integer())
            }
          | %{data: iodata(), media_type: binary(), media_category: binary(), additional_owners: list(pos_integer())}

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
      iex> {:ok, res} = Tw.V1_1.Media.upload(client, %{path: "/tmp/abc.png"})
      iex> Tw.V1_1.Tweet.create(client, %{status: "Tweets with a image", media_ids: [res.media_id]})
      {:ok, %Tw.V1_1.Tweet{}}

      iex> {:ok, res} = Tw.V1_1.Media.upload(client, %{data: png_binary, media_type: "image/png"})
      iex> Tw.V1_1.Tweet.create(client, %{status: "Tweets with a image", media_ids: [res.media_id]})
      {:ok, %Tw.V1_1.Tweet{}}

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/overview) for details.
  """
  @spec upload(Client.t(), upload_params(), Tw.HTTP.Client.options()) ::
          {:ok, upload_ok_result()}
          | {:error, Tw.V1_1.TwitterAPIError.t() | upload_error_result()}
  def upload(client, params, http_client_opts \\ [])

  def upload(client, %{path: path} = params, http_client_opts) do
    with {:ok, stat} <- File.stat(path),
         {:ok, media_type} <- infer_media_type(path),
         {:ok, device} <- File.open(path, [:binary, :read]) do
      try do
        params =
          params
          |> Map.delete(:path)
          |> Map.merge(%{device: device, media_type: media_type, total_bytes: stat.size})

        upload(client, params, http_client_opts)
      after
        File.close(device)
      end
    else
      error -> error
    end
  end

  def upload(client, %{device: device, media_type: media_type, total_bytes: _total_bytes} = params, http_client_opts) do
    params =
      params
      |> Map.delete(:device)
      |> Map.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, IO.binstream(device, @chunk_size), params, http_client_opts)
  end

  def upload(client, %{data: data, media_type: media_type} = params, http_client_opts) do
    params =
      params
      |> Map.delete(:data)
      |> Map.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, data |> IO.iodata_to_binary() |> chunks(), params, http_client_opts)
  end

  defp upload_sequence(client, chunks, params, http_client_opts) do
    with {:ok, init_result} <- initialize_upload(client, params, http_client_opts),
         :ok <- upload_chunks(client, init_result.media_id, chunks, http_client_opts),
         {:ok, finalize_result} <- finalize_upload(client, init_result.media_id, http_client_opts),
         {:ok, res} <- wait_for_processing(client, finalize_result, http_client_opts) do
      {:ok, res}
    else
      error -> error
    end
  end

  defp chunks(<<chunk::binary-size(@chunk_size), rest::binary>>), do: [chunk | chunks(rest)]
  defp chunks(rest), do: [rest]

  defp initialize_upload(client, params, http_client_opts) do
    upload_command(client, :post, params |> Map.put(:command, :INIT), http_client_opts)
  end

  defp upload_chunks(client, media_id, chunks, http_client_opts) do
    chunks
    |> Stream.with_index()
    |> Task.async_stream(fn {bin, i} ->
      upload_append(client, %{media_id: media_id, media: bin, segment_index: i}, http_client_opts)
    end)
    |> Enum.filter(&match?({:error, _}, &1))
    |> case do
      [] -> :ok
      [error | _] -> error
    end
  end

  defp upload_append(client, params, http_client_opts) do
    upload_command(client, :post, params |> Map.put(:command, :APPEND), http_client_opts)
  end

  defp finalize_upload(client, params, http_client_opts) do
    upload_command(client, :post, params |> Map.put(:command, :FINALIZE), http_client_opts)
  end

  defp wait_for_processing(client, finalize_result, http_client_opts)

  defp wait_for_processing(_client, %{processing_info: %{state: "failed"}} = res, _) do
    {:error, res}
  end

  defp wait_for_processing(_client, %{processing_info: %{state: "succeeded"}} = res, _) do
    {:ok, res}
  end

  defp wait_for_processing(client, %{processing_info: %{state: state} = processing_info} = res, http_client_opts)
       when state in ["pending", "in_progress"] do
    Process.sleep(:timer.seconds(processing_info.check_after_secs))

    case upload_command(client, :get, %{command: :STATUS, media_id: res.media_id}, http_client_opts) do
      {:ok, res} -> wait_for_processing(client, res, http_client_opts)
      error -> error
    end
  end

  defp wait_for_processing(_client, res, _), do: {:ok, res}

  @type upload_init_command_params :: %{
          required(:command) => :INIT,
          required(:total_bytes) => non_neg_integer(),
          required(:media_type) => binary(),
          optional(:media_category) => binary(),
          optional(:additional_owners) => list(User.id())
        }

  @type upload_append_command_params ::
          %{
            required(:command) => :APPEND,
            required(:media_id) => pos_integer(),
            required(:media) => binary(),
            required(:segment_index) => binary(),
            optional(:additional_owners) => list(User.id())
          }
          | %{
              required(:command) => :APPEND,
              required(:media_id) => pos_integer(),
              required(:media_data) => binary(),
              required(:segment_index) => binary(),
              optional(:additional_owners) => list(User.id())
            }

  @type upload_finalize_command_params :: %{
          required(:command) => :FINALIZE,
          required(:media_id) => pos_integer()
        }

  @type upload_status_command_params :: %{
          required(:command) => :STATUS,
          required(:media_id) => pos_integer()
        }

  @type upload_command_params ::
          upload_init_command_params()
          | upload_append_command_params()
          | upload_finalize_command_params()
          | upload_status_command_params()

  @spec upload_command(Client.t(), :get | :post, upload_command_params(), Tw.HTTP.Client.options()) ::
          {:ok, %{atom => term}} | {:error, term}
  def upload_command(client, method, params, http_client_opts) do
    with {:ok, resp} <- Client.request(client, method, "/media/upload.json", params, http_client_opts),
         {:ok, res} <- Client.decode_json(client, resp.body) do
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

      ".srt" ->
        {:ok, "application/x-subrip"}

      name ->
        {:error, "Could not infer media type from the extension `#{name}`"}
    end
  end

  defp category_from_type("image/gif"), do: "tweet_gif"
  defp category_from_type("image/" <> _), do: "tweet_image"
  defp category_from_type("video/" <> _), do: "tweet_video"
  defp category_from_type("application/x-subrip"), do: "subtitles"

  @type create_metadata_params :: %{
          media_id: pos_integer(),
          alt_text: %{
            text: binary()
          }
        }

  @doc """
  Add metadata to an uploaded medium by `POST media/metadata/create`

  > This endpoint can be used to provide additional information about the uploaded media_id. This feature is currently only supported for images and GIFs.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/api-reference/post-media-metadata-create) for details.

  ## Examples
      iex> {:ok, res} = Tw.V1_1.Media.upload(client, %{path: "/tmp/abc.png"})
      iex> Tw.V1_1.Media.create_metadata(client, %{media_id: res.media_id, alt_text: %{text: "dancing cat"}})
      {:ok, nil}

  """
  @spec create_metadata(Client.t(), create_metadata_params(), Tw.HTTP.Client.options()) ::
          {:ok, nil} | {:error, Tw.V1_1.TwitterAPIError.t()}
  def create_metadata(client, params, http_client_opts) do
    params = params |> Map.update!(:media_id, &to_string/1)

    with {:ok, _resp} <- Client.request(client, :post, "/media/metadata/create.json", params, http_client_opts) do
      {:ok, nil}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  @type bind_subtitles_params ::
          %{
            media_id: pos_integer(),
            subtitles: [%{media_id: binary() | pos_integer(), language_code: binary(), display_name: binary()}]
          }

  @doc """
  Bind subtitles to an uploaded video by requesting `POST media/subtitles/create`.

  > You can associate subtitles to video before or after Tweeting.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/api-reference/post-media-subtitles-create) for details.

  ## Examples
      iex> {:ok, video} = Tw.V1_1.Media.upload(client, "/tmp/abc.mp4")
      iex> {:ok, en_sub} = Tw.V1_1.Media.upload(client, "/tmp/en.srt")
      iex> subtitles = [%{media_id: en_sub.media_id, language_code: "EN", display_name: "English"}]
      iex> {:ok, en_sub} = Tw.V1_1.Media.bind_subtitles(client, %{media_id: video.media_id, subtitles: subtitles})
      {:ok, nil}
  """
  @spec bind_subtitles(Client.t(), bind_subtitles_params, Tw.HTTP.Client.options()) ::
          {:ok, nil} | {:error, Tw.V1_1.TwitterAPIError.t()}
  def bind_subtitles(client, %{media_id: media_id, subtitles: subtitles}, http_client_opts) do
    params = %{
      media_id: media_id,
      media_category: "TweetVideo",
      subtitle_info: %{
        subtitles: subtitles
      }
    }

    with {:ok, _resp} <- Client.request(client, :post, "/media/subtitles/create.json", params, http_client_opts) do
      {:ok, nil}
    else
      {:error, message} ->
        {:error, message}
    end
  end

  @type unbind_subtitles_params :: %{
          media_id: pos_integer(),
          subtitles: [%{language_code: binary()}]
        }
  @doc """
  Unbind subtitles to an uploaded video by requesting `POST media/subtitles/delete`.

  > You can dissociate subtitles from a video before or after Tweeting.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/api-reference/post-media-subtitles-delete) for details.

  ## Examples
      iex> {:ok, en_sub} = Tw.V1_1.Media.unbind_subtitles(client, %{media_id: video.media_id, subtitles: [%{language_code: "EN"}]})
      {:ok, nil}
  """

  @spec unbind_subtitles(Client.t(), unbind_subtitles_params(), Tw.HTTP.Client.options()) ::
          {:ok, nil} | {:error, Tw.V1_1.TwitterAPIError.t()}
  def unbind_subtitles(client, %{media_id: media_id, subtitles: subtitles}, http_client_opts) do
    params = %{
      media_id: media_id,
      media_category: "TweetVideo",
      subtitle_info: %{
        subtitles: subtitles
      }
    }

    with {:ok, _resp} <- Client.request(client, :post, "/media/subtitles/delete.json", params, http_client_opts) do
      {:ok, nil}
    else
      {:error, message} ->
        {:error, message}
    end
  end
end
