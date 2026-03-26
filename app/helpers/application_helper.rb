module ApplicationHelper
  def website_detail
    WebsiteDetail.last&.attributes
  end

  def auth_link
    if user_signed_in?
      button_to destroy_user_session_path,
            method: :delete,
            class: "main-menu__login" do
        content_tag(:i, "", class: "fal fa-sign-out-alt")
      end

    else
      link_to new_user_session_path, class: "main-menu__login" do
        content_tag(:i, "", class: "fal fa-user")
      end
    end
  end
end
