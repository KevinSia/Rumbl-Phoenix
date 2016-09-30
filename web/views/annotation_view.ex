defmodule Rumbl.AnnotationView do
  use Rumbl.Web, :view

  def render("annotation.json", %{annotation: ann}) do
    %{
      id: ann.id,
      body: ann.body,
      at: ann.at,
      # the render one function provides conveniences
      # such as handling possible nil results
      user: render_one(ann.user, Rumbl.UserView, "user.json")
    }
  end
end
