class UserObserver < ActiveRecord::Observer
  def before_validation(user)
    user.password = SecureRandom.hex(4) unless user.password || user.persisted?
  end

  def after_create(user)
    return if user.email =~ /change-your-email\+[0-9]+@neighbor\.ly/
    WelcomeWorker.perform_async(user.id)
  end

  def after_save(user)
    if user.completeness_progress.to_i < 100
      UpdateCompletenessProgressWorker.perform_async(user.id)
    end
  end
end
