defmodule LedgerStarterWeb.AuthComponents do
  @moduledoc "The StartKit auth frame (the kit's `auth_page` + `auth_art`) shared by every guest/onboarding screen."
  use LedgerStarterWeb, :html

  @doc """
  Full-height two-halves screen: the form column on the left, the art with
  floating chips (and optionally a testimonial) on the right.
  """
  attr :id, :string, required: true, doc: "prefix of the art ids (one per page)"
  attr :footer_right, :string, default: nil
  attr :flash, :map, default: %{}

  slot :inner_block, required: true

  slot :chip, doc: "attrs: icon, title, subtitle, top, left, right, bottom" do
    attr :icon, :string
    attr :title, :string
    attr :subtitle, :string
    attr :top, :string
    attr :left, :string
    attr :right, :string
    attr :bottom, :string
  end

  slot :quote do
    attr :author, :string, required: true
    attr :role, :string
    attr :initials, :string
  end

  def auth_screen(assigns) do
    ~H"""
    <div class="h-screen bg-page">
      <.toaster flash={@flash} close_label={gettext("Fechar")} />
      <.auth_page brand="StartKit" mark="">
        {render_slot(@inner_block)}
        <:footer>
          <span>© 2026 StartKit</span>
          <span :if={@footer_right}>{@footer_right}</span>
          <span :if={!@footer_right}>
            <.link href={~p"/privacidade"}>{gettext("Privacidade")}</.link>
            · <.link href={~p"/termos"}>{gettext("Termos")}</.link>
          </span>
          <.locale_switcher />
        </:footer>
        <:art>
          <.auth_art id={"#{@id}-art"}>
            <:chip
              :for={c <- @chip}
              top={c[:top]}
              left={c[:left]}
              right={c[:right]}
              bottom={c[:bottom]}
            >
              <.icon boxed name={c.icon} />
              <span><b>{c.title}</b><small>{c.subtitle}</small></span>
            </:chip>
            <:quote :for={q <- @quote} author={q.author} role={q[:role]} initials={q[:initials]}>
              {render_slot(q)}
            </:quote>
          </.auth_art>
        </:art>
      </.auth_page>
    </div>
    """
  end

  @doc "Google button, only when OAuth is configured."
  attr :label, :string, required: true

  def google_button(assigns) do
    ~H"""
    <.oauth_button
      :if={LedgerStarter.Auth.Google.enabled?()}
      provider="google"
      block
      href={~p"/auth/google"}
    >
      {@label}
    </.oauth_button>
    """
  end

  @doc "The `ou com e-mail` divider of the auth column."
  attr :label, :string, default: nil

  def or_divider(assigns) do
    ~H"""
    <div class="or">{@label || gettext("ou com e-mail")}</div>
    """
  end

  @doc "Password strength for the meter: nil, weak, fair, good or strong."
  def password_strength(nil), do: nil
  def password_strength(""), do: nil

  def password_strength(password) do
    score =
      Enum.count(
        [
          String.length(password) >= 12,
          String.length(password) >= 16,
          Regex.match?(~r/[a-z]/, password) and Regex.match?(~r/[A-Z]/, password),
          Regex.match?(~r/\d/, password),
          Regex.match?(~r/[^A-Za-z0-9]/, password)
        ],
        & &1
      )

    cond do
      String.length(password) < 8 -> "weak"
      score <= 2 -> "fair"
      score == 3 -> "good"
      true -> "strong"
    end
  end
end
