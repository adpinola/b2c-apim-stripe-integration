import express from "express";
import querystring from "querystring";
import { ApimService } from "../services/apimService";

export const register = (app: express.Application) => {
  const apimService = new ApimService();

  app.post("/enrich-token", async (req, res) => {
    const subject = req.body.objectId;
    // tslint:disable-next-line:no-console
    console.log(req.body)
    try {
      const keys = await apimService.getSubscriptionKeys(`${subject}-enterprise`);
      const returnClaims = {
        action: "Continue",
        extension_PrimaryKey: keys.primaryKey,
        extension_SecondaryKey: keys.secondaryKey,
      };
      res.status(200).json(returnClaims);
    } catch {
      const returnClaims = {
        action: "Continue",
        extension_PrimaryKey: "<unset>",
        extension_SecondaryKey: "<unset>",
      };
      res.status(200).json(returnClaims);
    }
  });

  app.post("/subscribe", async (req, res) => {
    const productId = "enterprise";
    const subscribeRequest: B2CSubscriptionRequest = {
      productId,
      userId: req.body.localAccountId as string, // This is hte localAccountId parameter from the JWT
      userEmail: req.body.userEmail as string, // This is hte username parameter from the JWT
    };

    const redirectQuery = querystring.stringify({
      operation: "subscribe",
      userId: subscribeRequest.userId,
      productId: subscribeRequest.productId,
      userEmail: subscribeRequest.userEmail,
    });

    res.redirect(`/checkout?${redirectQuery}`);
  });

  /** Checkout, using redirect to specific payment provider view */
  app.get("/checkout", async (req, res) => {
    const operation = req.query.operation as string;
    const userId = req.query.userId as string;
    const productId = req.query.productId as string;
    const userEmail = req.query.userEmail as string;

    const subscribeRequest: B2CSubscriptionRequest = {
      operation,
      productId,
      userId,
      userEmail,
    };

    res.render('checkout-stripe', {
      subscribeRequest,
      title: "Checkout",
    });
  });

  app.get("/success", (req, res) => {
    res.render("success", { title: "Payment Succeeded" });
  });

  app.get("/fail", (req, res) => {
    const subscribeRequest: B2CSubscriptionRequest = {
      operation: req.query.operation as string,
      productId: req.query.productId as string,
      userId: req.query.userId as string,
      userEmail: req.query.userEmail as string,
    };

    const checkoutQuery = querystring.stringify({
      userId: subscribeRequest.userId,
      operation: subscribeRequest.operation,
      productId: subscribeRequest.productId,
      userEmail: subscribeRequest.userEmail,
    });

    const checkoutUrl = `/checkout?${checkoutQuery}`;

    res.render("fail", { title: "Payment Failed", checkoutUrl });
  });

  /** Checkout cancelled, redirect to payment cancelled view */
  app.get("/cancel", (req, res) => {
    const subscribeRequest: B2CSubscriptionRequest = {
      operation: req.query.operation as string,
      productId: req.query.productId as string,
      userId: req.query.userId as string,
      userEmail: req.query.userEmail as string,
    };

    const checkoutQuery = querystring.stringify({
      userId: subscribeRequest.userId,
      operation: subscribeRequest.operation,
      productId: subscribeRequest.productId,
      userEmail: subscribeRequest.userEmail,
    });

    const checkoutUrl = `/checkout?${checkoutQuery}`;

    res.render("cancel", { title: "Payment Cancelled", checkoutUrl });
  });
};

interface B2CSubscriptionRequest {
  operation?: string;
  userId: string;
  productId: string;
  userEmail: string;
}
