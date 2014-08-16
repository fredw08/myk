class PostsController < BaseController

  private

  def post_params
    params.require(:post).permit(Post.attribute_names.map(&:to_sym))
  end
end
