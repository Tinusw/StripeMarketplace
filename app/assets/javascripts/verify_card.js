jQuery(function($) {
  Stripe.setPublishableKey(gon.stripe_key);

  function createCardToken(event) {
   Stripe.card.createToken({
      number: $('#card_number').val(),
      cvc: $('#card-cvc').val(),
      exp_month: $('#card_month').val(),
      exp_year: $('#card_year').val()
    }, stripeResponseHandler);
    console.log('token created')
  }

  function stripeResponseHandler(status, response) {
    var $form = $('.add-card');

    if (response.error) {
      // Show the error on the form
      $("#error").text(response.error.message)
      $form.find("input[type=submit]").prop('disabled', false);
    } else {
      // response contains id and card, which contains additional card details
      var token = response.id;
      console.log(token);
      // Insert the token into the form so it gets submitted to the server
      $("input[id=stripe_temporary_token]").val(token)
      // and submit manually
      $form.get(0).submit();
    }
  };

  // If the user doesn't have a stripe customer account & credit card currently tied to their account, this function will execute and intercept the submit event to obtain a stripe token. Once it has it, it will execute the submit action
  $('#card-unavailable').each(function() {
    $('.add-card').submit(function(event) {
      console.log('no card')
      createCardToken();
      // Prevent the form from submitting with the default action, we want the token first.
      return false;
    })
  })
});
