defmodule Yarn do
  require HTTPoison
  require Poison
  @spec api_endpoint(String.t()) :: <<_::64, _::_*8>>
  def api_endpoint(yarnpod) do
    "https://#{yarnpod}/api/v1"
  end

  @spec get_jwt_token(String.t(), String.t(), String.t()) :: String.t()
  def get_jwt_token(username, password, endpoint) do
    {:ok, response} =
      HTTPoison.post(
        "#{endpoint}/auth",
        Poison.encode!(%{username: username, password: password}),
        %{"Content-Type" => "application/json"}
      )

    Poison.decode!(response.body)["token"]
  end

  @spec authenticated_headers(String.t()) :: %{optional(<<_::40, _::_*56>>) => binary}
  def authenticated_headers(token) do
    %{"Token" => "#{token}", "Content-Type" => "application/json"}
  end

  def post_twt(token, yarnpod, twt) do
    {:ok, response} =
      HTTPoison.post(
        "#{api_endpoint(yarnpod)}/post",
        Poison.encode!(%{text: twt, post_as: ""}),
        authenticated_headers(token)
      )

    Poison.decode!(response.body)
  end

  def get_profile(yarnpod, username) do
    {:ok, response} =
      HTTPoison.get(
        "#{api_endpoint(yarnpod)}/profile/#{username}",
        %{"Content-Type" => "application/json"}
      )

    Poison.decode!(response.body)
  end
  def reply_twt(token, yarnpod, hash, twt) do
    # damn that's some ugly code
    post_twt(token, yarnpod, "(##{hash}) #{twt}")
    # well it basically just merges the hash and twt into a single string so it looks like
    # --> "(#abcdefg) yes you're so right!"
    # and then posts it to your yarn account where yarn can aggregate it into being a reply to
    # the twt with hash of abcdefg, in this example
  end
end
