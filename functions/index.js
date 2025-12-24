const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();

const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY"); /// i deleted the real one for security reasons

exports.createPaymentIntent = onCall(
  {
    region: "us-central1",
    secrets: [stripeSecretKey],
  },
  async (request) => {
    const data = request.data || {};
    const amount = data.amount;
    const currency = (data.currency || "usd").toLowerCase();

    if (!Number.isInteger(amount) || amount <= 0) {
      throw new HttpsError("invalid-argument", "amount must be a positive integer in the smallest currency unit");
    }

    if (typeof currency !== "string" || currency.length < 3 || currency.length > 10) {
      throw new HttpsError("invalid-argument", "currency is invalid");
    }

    const stripe = require("stripe")(stripeSecretKey.value());

    try {
      const intent = await stripe.paymentIntents.create({
        amount,
        currency,
        automatic_payment_methods: { enabled: true },
      });

      return {
        clientSecret: intent.client_secret,
      };
    } catch (err) {
      throw new HttpsError("internal", err?.message || "Stripe error");
    }
  }
);
