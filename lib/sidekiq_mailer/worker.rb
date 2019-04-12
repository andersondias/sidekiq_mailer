class Sidekiq::Mailer::Worker
  include Sidekiq::Worker

  def perform(mailer_class, action, params)
    mailer_class.constantize.send(action, *params).deliver_now!
  end
end
