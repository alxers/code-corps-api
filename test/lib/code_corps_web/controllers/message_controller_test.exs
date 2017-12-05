defmodule CodeCorpsWeb.MessageControllerTest do
  use CodeCorpsWeb.ApiCase, resource_name: :message

  @valid_attrs %{
    body: "Test body.",
    initiated_by: "admin",
    subject: "A test subject"
  }

  @invalid_attrs %{
    body: nil,
    initiated_by: "admin",
    subject: nil
  }

  describe "index" do
    @tag :authenticated
    test "lists all entries", %{conn: conn} do
      [message_1, message_2] = insert_pair(:message)

      conn
      |> request_index
      |> json_response(200)
      |> assert_ids_from_response([message_1.id, message_2.id])
    end
  end

  describe "show" do
    @tag :authenticated
    test "shows chosen resource", %{conn: conn, current_user: user} do
      message = insert(:message, initiated_by: "user", author: user)

      conn
      |> request_show(message)
      |> json_response(200)
      |> assert_id_from_response(message.id)
    end

    test "renders 401 when unauthenticated", %{conn: conn} do
      message = insert(:message)
      assert conn |> request_show(message) |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when unauthorized", %{conn: conn} do
      message = insert(:message)
      assert conn |> request_show(message) |> json_response(403)
    end
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource when data is valid", %{conn: conn, current_user: user} do
      project = insert(:project)
      insert(:project_user, project: project, user: user, role: "owner")
      attrs = @valid_attrs |> Map.merge(%{author_id: user.id, project_id: project.id})

      assert conn |> request_create(attrs) |> json_response(201)
    end

    @tag :authenticated
    test "does not create resource and renders 422 when data is invalid", %{
      conn: conn,
      current_user: user
    } do
      project = insert(:project)
      insert(:project_user, project: project, user: user, role: "owner")
      attrs = @invalid_attrs |> Map.merge(%{author_id: user.id, project_id: project.id})

      assert conn |> request_create(attrs) |> json_response(422)
    end

    test "does not create resource and renders 401 when not authenticated", %{conn: conn} do
      assert conn |> request_create |> json_response(401)
    end

    @tag :authenticated
    test "renders 403 when not authorized", %{conn: conn} do
      assert conn |> request_create |> json_response(403)
    end

    @tag :authenticated
    test "renders 403 when initiated by admin and not authorized", %{conn: conn, current_user: user} do
      project = insert(:project)
      insert(:project_user, project: project, user: user, role: "contributor")
      params = %{
        author_id: user.id,
        initiated_by: "admin",
        project_id: project.id
      }
      attrs = @valid_attrs |> Map.merge(params)

      assert conn |> request_create(attrs) |> json_response(403)
    end
  end
end
