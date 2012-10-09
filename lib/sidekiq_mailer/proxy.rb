class Sidekiq::Mailer::Proxy
  delegate :to_s, :to => :actual_message

  def initialize(mailer_class, method_name, *args)
    @mailer_class = mailer_class
    @method_name = method_name
    *@args = *args
  end

  def actual_message
    @actual_message ||= @mailer_class.send(:new, @method_name, *@args).message
  end

  def deliver
    params = {
      'class' => Sidekiq::Mailer::Worker,
      'args' => [@mailer_class.to_s, @method_name, *@args]
    }
    Sidekiq::Mailer::Worker.client_push(params.merge(@mailer_class.get_sidekiq_options))
  end

  # def deliver_at(time)
  #   return deliver! if environment_excluded?

  #   unless resque.respond_to? :enqueue_at
  #     raise "You need to install resque-scheduler to use deliver_at"
  #   end

  #   if @mailer_class.deliver?
  #     resque.enqueue_at(time, @mailer_class, @method_name, *@args)
  #   end
  # end

  # def deliver_in(time)
  #   return deliver! if environment_excluded?

  #   unless resque.respond_to? :enqueue_in
  #     raise "You need to install resque-scheduler to use deliver_in"
  #   end

  #   if @mailer_class.deliver?
  #     resque.enqueue_in(time, @mailer_class, @method_name, *@args)
  #   end
  # end

  def deliver!
    actual_message.deliver!
  end

  def method_missing(method_name, *args)
    actual_message.send(method_name, *args)
  end
end