class Post < ActiveRecord::Base
  structure do
    title      :string, validates: :presence
    content    :text,   validates: :presence
    post_date  :date

    timestamps
  end

  scope :search_keyword, ->(kw) {
    where("content ILIKE ?", kw)
  }

  def build
    self.post_date ||= Date.today
  end
end
