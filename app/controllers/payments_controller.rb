class PaymentsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @user = current_user
    token = params[:stripeToken]
    # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        amount: (@product.price * 100),
        currency: "eur",
        source: token,
        description: params[:stripeEmail]
      )

    if charge.paid
     Order.create(:product_id, :user_id, :total)
    end

    rescue Stripe::CardError => e
    # The card has been declined
    body = e.json_body
    err = body[:error]
    flash[:error] = "Leider ist bei der Bezahlung etwas schief gegangen: #{err[:message]}"
    end
    redirect_to product_path(@product)
  end

end
