import * as express from "express";
import * as apimDelegationRoutes from "./apim-delegation";
import * as stripeRoutes from "./stripe";
import { BillingService } from "../services/billingService";
import { StripeBillingService } from "../services/stripeBillingService";

export const register = (app: express.Application) => {
    let billingService: BillingService;
    stripeRoutes.register(app);
    billingService = new StripeBillingService();
    apimDelegationRoutes.register(app);
};