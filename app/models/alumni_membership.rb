class AlumniMembership < ActiveRecord::Base
  belongs_to :user

  before_destroy :cancel_subscription

  #def self.active_as_of(time)
  #  where("deactivated_on is null OR deactivated_on > ?", time)
  #end

  def self.active
    where(status: "active")
  end

  def active?
    status == "active"
  end

  def plan
    "alumni_#{interval}ly"
  end

  def member_since
    created_at.strftime("%B %e, %Y")
  end

  private

    def cancel_subscription
      if stripe_subscription_id
        CancelStripeSubscription.perform_async(
          stripe_customer_id,
          stripe_subscription_id)

        self.update(
          deactivated_on: Time.zone.today,
          stripe_subscription_id: nil,
          status: "canceled")
      end
    end

    def stripe_customer_id
      user.stripe_customer_id
    end
end
