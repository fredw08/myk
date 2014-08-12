class Post < ActiveRecord::Base
  structure do
    title      :string
    content    :text
    post_date  :date

    timestamps
  end

  def build
    self.post_date ||= Date.today
  end
end
