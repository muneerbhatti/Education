module ApplicationHelper
  def website_detail
    WebsiteDetail.last&.attributes
  end
end
