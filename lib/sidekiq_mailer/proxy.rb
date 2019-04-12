class Sidekiq::Mailer::Proxy
  delegate :deliver!, :to => :deliver_now!

  def initialize(mailer_class, method_name, *args)
    @mailer_class = mailer_class
    @method_name = method_name
    *@args = *args
  end

  def deliver
    return deliver_now! if Sidekiq::Mailer.excludes_current_environment?
    Sidekiq::Mailer::Worker.client_push(to_sidekiq)
  end

  def deliver_now!
    ::ActionMailer::MessageDelivery.new(@mailer_class, @method_name, *@args).deliver_now!
  end

  private

  def excluded_environment?
    Sidekiq::Mailer.excludes_current_environment?
  end

  def to_sidekiq
    params = {
      'class' => Sidekiq::Mailer::Worker,
      'args' => [@mailer_class.to_s, @method_name, @args]
    }
    params.merge(@mailer_class.get_sidekiq_options)
  end
end
