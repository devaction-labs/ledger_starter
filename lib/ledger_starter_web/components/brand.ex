defmodule LedgerStarterWeb.Brand do
  @moduledoc """
  The StartKit brand: the teal mark (`/images/mark.svg`) plus the "StartKit" wordmark.

  The mark reads on light and dark backgrounds alike; the wordmark is live text in the display
  face and follows `currentColor`, so it flips with the theme.
  """
  use Phoenix.Component

  attr :size, :integer, default: 28, doc: "The side of the mark, in px."
  attr :word, :boolean, default: true, doc: "Shows the \"StartKit\" wordmark after the mark."
  attr :class, :any, default: nil
  attr :rest, :global

  def brand_logo(assigns) do
    ~H"""
    <span
      data-part="startkit-logo"
      class={[
        "inline-flex items-center gap-2.5 font-display text-[17px] leading-none font-[650] tracking-[-.035em]",
        @class
      ]}
      {@rest}
    >
      <img src="/images/mark.svg" alt="" width={@size} height={@size} class="flex-none" />
      <span :if={@word}>StartKit</span>
    </span>
    """
  end
end
