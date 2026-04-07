class NewslettersController < ApplicationController
  def subscribe
    @newsletter = Newsletter.find_or_initialize_by(email: newsletter_params[:email])
    @newsletter.status = :subscribed

    if @newsletter.save
      redirect_to newsletter_subscribed_path
    else
      flash[:alert] = @newsletter.errors.full_messages.join(", ")
      redirect_back(fallback_location: root_path)
    end
  end

  def unsubscribe
    @newsletter = Newsletter.find_by(email: params[:email] || newsletter_params[:email])

    if @newsletter&.update(status: :unsubscribed)
      render plain: "Successfully unsubscribed from newsletter."
    else
      render plain: "Email not found in our newsletter list."
    end
  end

  def subscribed
  end

  private

  def newsletter_params
    params.require(:newsletter).permit(:email)
  end
end
