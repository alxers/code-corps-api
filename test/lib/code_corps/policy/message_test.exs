defmodule CodeCorps.Policy.MessageTest do
  use CodeCorps.PolicyCase

  import CodeCorps.Policy.Message, only: [create?: 2, show?: 2]

  defp params_for(initiated_by, project_id, user_id) do
    %{
      "initiated_by" => initiated_by,
      "author_id" => user_id,
      "project_id" => project_id
    }
  end

  describe "show?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      message = insert(:message, initiated_by: "user", author: author)

      assert show?(author, message)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      message = insert(:message, initiated_by: "user")

      refute show?(user, message)
    end

    test "returns false when user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns false when user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      message = insert(:message, initiated_by: "user", project: project)

      refute show?(user, message)
    end

    test "returns true when user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end

    test "returns true when user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      message = insert(:message, initiated_by: "user", project: project)

      assert show?(user, message)
    end
  end

  describe "create?" do
    test "returns true when initiated by user and user is the author" do
      author = insert(:user)
      params = params_for("user", 1, author.id)

      assert create?(author, params)
    end

    test "returns false when initiated by user and user is not the author" do
      user = insert(:user)
      params = params_for("user", 1, -1)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a pending project member" do
      %{project: project, user: user} = insert(:project_user, role: "pending")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns false when initiated by admin and user is a project contributor" do
      %{project: project, user: user} = insert(:project_user, role: "contributor")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      refute create?(user, params)
    end

    test "returns true when initiated by admin and user is a project admin" do
      %{project: project, user: user} = insert(:project_user, role: "admin")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end

    test "returns true when initiated by admin and user is project owner" do
      %{project: project, user: user} = insert(:project_user, role: "owner")
      author = insert(:user)
      params = params_for("admin", project.id, author.id)

      assert create?(user, params)
    end
  end
end
