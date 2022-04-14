defmodule Tw.V1_1.Media do
  @moduledoc """
  Media data structure and related functions.

  https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/entities
  """

  alias Tw.V1_1.Client
  alias Tw.V1_1.Sizes
  alias Tw.V1_1.Tweet
  alias Tw.V1_1.User

  @type id :: pos_integer()

  @enforce_keys [
    :additional_media_info,
    :video_info,
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
    :additional_media_info,
    :video_info,
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
          additional_media_info:
            %{
              optional(:title) => binary(),
              optional(:description) => binary(),
              optional(:embeddable) => boolean(),
              optional(:monetizable) => boolean(),
              optional(:source_user) => User.t()
            }
            | nil,
          video_info:
            %{
              optional(:duration_millis) => non_neg_integer(),
              aspect_ratio: list(pos_integer()),
              variants: list(%{bitrate: non_neg_integer(), content_type: binary(), url: binary()})
            }
            | nil,
          display_url: binary(),
          expanded_url: binary(),
          id: id(),
          id_str: binary(),
          indices: list(non_neg_integer()),
          media_url: binary(),
          media_url_https: binary(),
          sizes: Sizes.t(),
          source_status_id: Tweet.id() | nil,
          source_status_id_str: Tweet.id() | nil,
          type: :photo | :video | :animated_gif,
          url: binary()
        }
  @spec decode!(map) :: t
  @doc """
  Decode JSON-decoded map into `t:t/0`
  """
  def decode!(json) do
    json =
      json
      |> Map.update!(:type, &String.to_atom/1)
      |> Map.update!(:sizes, &Sizes.decode!/1)

    struct(__MODULE__, json)
  end

  @type upload_params ::
          %{
            required(:path) => Path.t(),
            optional(:media_category) => binary(),
            optional(:additional_owners) => list(pos_integer())
          }
          | %{
              required(:device) => IO.device(),
              required(:media_type) => binary(),
              required(:total_bytes) => pos_integer(),
              optional(:media_category) => binary(),
              optional(:additional_owners) => list(pos_integer())
            }
          | %{
              required(:data) => iodata(),
              required(:media_type) => binary(),
              optional(:media_category) => binary(),
              optional(:additional_owners) => list(pos_integer())
            }

  @type upload_ok_result :: %{
          media_id: id(),
          media_id_string: binary(),
          expires_after_secs: pos_integer()
        }

  @type upload_error_result :: %{
          media_id: id(),
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
  @spec upload(Client.t(), upload_params()) ::
          {:ok, upload_ok_result()}
          | {:error, :file.posix() | Client.error() | upload_error_result()}
  def upload(client, params)

  def upload(client, %{path: path} = params) do
    with {:ok, stat} <- File.stat(path),
         {:ok, media_type} <- infer_media_type(path),
         {:ok, device} <- File.open(path, [:binary, :read]) do
      try do
        params =
          params
          |> Map.delete(:path)
          |> Map.merge(%{device: device, media_type: media_type, total_bytes: stat.size})

        upload(client, params)
      after
        File.close(device)
      end
    end
  end

  def upload(client, %{device: device, media_type: media_type, total_bytes: _total_bytes} = params) do
    params =
      params
      |> Map.delete(:device)
      |> Map.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, IO.binstream(device, @chunk_size), params)
  end

  def upload(client, %{data: data, media_type: media_type} = params) do
    params =
      params
      |> Map.delete(:data)
      |> Map.put_new_lazy(:total_bytes, fn -> IO.iodata_length(data) end)
      |> Map.put_new_lazy(:media_category, fn -> category_from_type(media_type) end)

    upload_sequence(client, data |> IO.iodata_to_binary() |> chunks(), params)
  end

  defp upload_sequence(client, chunks, params) do
    with {:ok, init_result} <- initialize_upload(client, params),
         :ok <- upload_chunks(client, init_result.media_id, chunks),
         {:ok, finalize_result} <- finalize_upload(client, init_result.media_id) do
      wait_for_processing(client, finalize_result)
    end
  end

  defp chunks(<<chunk::binary-size(@chunk_size), rest::binary>>), do: [chunk | chunks(rest)]
  defp chunks(rest), do: [rest]

  defp initialize_upload(client, params) do
    upload_command(client, :post, params |> Map.put(:command, :INIT))
  end

  defp upload_chunks(client, media_id, chunks) do
    chunks
    |> Stream.with_index()
    |> Task.async_stream(fn {bin, i} ->
      upload_append(client, %{media_id: media_id, media: bin, segment_index: i})
    end)
    |> Enum.filter(&match?({:error, _}, &1))
    |> case do
      [] -> :ok
      [error | _] -> error
    end
  end

  defp upload_append(client, params) do
    upload_command(client, :post, params |> Map.put(:command, :APPEND))
  end

  defp finalize_upload(client, media_id) do
    upload_command(client, :post, %{command: :FINALIZE, media_id: media_id})
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

    case upload_command(client, :get, %{command: :STATUS, media_id: res.media_id}) do
      {:ok, res} -> wait_for_processing(client, res)
      error -> error
    end
  end

  defp wait_for_processing(_client, res), do: {:ok, res}

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

  @spec upload_command(Client.t(), :get | :post, upload_command_params()) ::
          {:ok, %{atom => term}} | {:error, term}
  def upload_command(client, method, params) do
    Client.request(client, method, "/media/upload.json", params)
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
          media_id: id(),
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
      {:ok, ""}

  """
  @spec create_metadata(Client.t(), create_metadata_params()) ::
          {:ok, binary()} | {:error, Client.error()}
  def create_metadata(client, params) do
    params = params |> Map.update!(:media_id, &to_string/1)

    Client.request(client, :post, "/media/metadata/create.json", params)
  end

  @type bind_subtitles_params ::
          %{
            media_id: id(),
            subtitles: [%{media_id: binary() | pos_integer(), language_code: binary(), display_name: binary()}]
          }

  @doc """
  Bind subtitles to an uploaded video by requesting `POST media/subtitles/create`.

  > You can associate subtitles to video before or after Tweeting.

  See [the Twitter API documentation](https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/api-reference/post-media-subtitles-create) for details.

  ## Examples
      iex> {:ok, video} = Tw.V1_1.Media.upload(client, %{path: "/tmp/abc.mp4"})
      iex> {:ok, en_sub} = Tw.V1_1.Media.upload(client, %{path: "/tmp/en.srt"})
      iex> subtitles = [%{media_id: en_sub.media_id, language_code: "EN", display_name: "English"}]
      iex> {:ok, en_sub} = Tw.V1_1.Media.bind_subtitles(client, %{media_id: video.media_id, subtitles: subtitles})
      {:ok, nil}
  """
  @spec bind_subtitles(Client.t(), bind_subtitles_params) ::
          {:ok, nil} | {:error, Client.error()}
  def bind_subtitles(client, %{media_id: media_id, subtitles: subtitles}) do
    params = %{
      media_id: media_id |> to_string(),
      media_category: "TweetVideo",
      subtitle_info: %{
        subtitles: subtitles |> Enum.map(fn sub -> sub |> Map.update!(:media_id, &to_string/1) end)
      }
    }

    Client.request(client, :post, "/media/subtitles/create.json", params)
  end

  @type unbind_subtitles_params :: %{
          media_id: id(),
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

  @spec unbind_subtitles(Client.t(), unbind_subtitles_params()) ::
          {:ok, nil} | {:error, Client.error()}
  def unbind_subtitles(client, %{media_id: media_id, subtitles: subtitles}) do
    params = %{
      media_id: media_id |> to_string(),
      media_category: "TweetVideo",
      subtitle_info: %{
        subtitles: subtitles
      }
    }

    Client.request(client, :post, "/media/subtitles/delete.json", params)
  end
end
