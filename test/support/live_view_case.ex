defmodule ShinarWeb.LiveViewCase do
  @moduledoc """
  Test case for LiveView feature tests.

  Provides `Phoenix.ConnTest` for building connections and
  `Phoenix.LiveViewTest` for driving LiveView pages.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint ShinarWeb.Endpoint

      use ShinarWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import ShinarWeb.LiveViewCase
    end
  end

  setup tags do
    Shinar.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
