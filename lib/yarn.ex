defmodule Yarn do
  require HTTPoison
  require Jason

  def yarn_twtxt_link(yarn_id) do
    ["", profile_name, profile_domain] = String.split(yarn_id, "@")

    "https://#{profile_domain}/user/#{profile_name}/twtxt.txt"
  end

  # returns a session object authenticated methods can use
  def login(yarnpod, username, password) do
    Jason.decode!(
      # yes this is extremely ugly and i should not be doing it TODO will fix later
      Jason.encode!(%{
        token: get_jwt_token(username, password, api_endpoint(yarnpod)),
        yarnpod: yarnpod
      })
    )
  end

  @spec api_endpoint(String.t()) :: <<_::64, _::_*8>>
  def api_endpoint(yarnpod) do
    "https://#{yarnpod}/api/v1"
  end

  @spec get_jwt_token(String.t(), String.t(), String.t()) :: String.t()
  def get_jwt_token(username, password, endpoint) do
    {:ok, response} =
      HTTPoison.post(
        "#{endpoint}/auth",
        Jason.encode!(%{username: username, password: password}),
        %{"Content-Type" => "application/json"}
      )

    Jason.decode!(response.body)["token"]
  end

  @spec authenticated_headers(String.t()) :: %{optional(<<_::40, _::_*56>>) => binary}
  def authenticated_headers(token) do
    %{"Token" => "#{token}", "Content-Type" => "application/json"}
  end

  def post_twt(session, twt) do
    {:ok, response} =
      HTTPoison.post(
        "#{api_endpoint(session["yarnpod"])}/post",
        Jason.encode!(%{text: twt, post_as: ""}),
        authenticated_headers(session["token"])
      )

    Jason.decode!(response.body)
  end

  def follow(session, url, nick) do
    {:ok, response} =
      HTTPoison.post(
        "#{api_endpoint(session["yarnpod"])}/follow",
        Jason.encode!(%{nick: "#{nick}", url: "#{url}"}),
        authenticated_headers(session["token"])
      )

    Jason.decode!(response.body)
  end

  def get_timeline(session, page) do
    {:ok, response} =
      HTTPoison.post(
        "#{api_endpoint(session["yarnpod"])}/timeline",
        Jason.encode!(%{page: "#{page}"}),
        authenticated_headers(session["token"])
      )

    response
    # Jason.decode!(response.body)
  end

  def get_profile(yarnpod, username) do
    {:ok, response} =
      HTTPoison.get(
        "#{api_endpoint(yarnpod)}/profile/#{username}",
        %{"Content-Type" => "application/json"}
      )

    Jason.decode!(response.body)
  end

  # def get_profile_twts(yarnpod, username, page) do
  #   {:ok, response} =
  #     HTTPoison.get(
  #       "#{api_endpoint(yarnpod)}/profile/#{username}/twts?page=#{page}",
  #       %{"Content-Type" => "application/json"}
  #     )

  #   Jason.decode!(response.body)
  # end

  def reply_twt(session, hash, twt) do
    # damn that's some ugly code
    post_twt(session, "(##{hash}) #{twt}")
    # well it basically just merges the hash and twt into a single string so it looks like
    # --> "(#abcdefg) yes you're so right!"
    # and then posts it to your yarn account where yarn can aggregate it into being a reply to
    # the twt with hash of abcdefg, in this example
  end
end
