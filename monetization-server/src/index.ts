import express from "express";
import expressLayouts from "express-ejs-layouts";
import path from "path";
import dotenv from "dotenv";
import { CronJob } from "cron";
import * as routes from "./routes/index";
import { StripeBillingService } from "./services/stripeBillingService";

dotenv.config();

const app = express();

app.use(express.urlencoded({ extended: true }));

// Use JSON parser for all non-webhook routes
app.use(
  (
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ): void => {
    if (req.originalUrl.startsWith("/webhook/")) {
      next();
    } else {
      res.header("Access-Control-Allow-Origin", process.env.ALLOWED_ORIGINS);
      res.header(
        "Access-Control-Allow-Methods",
        "GET, POST, OPTIONS, PUT, PATCH, DELETE"
      );
      res.header("Access-Control-Allow-Headers", "Content-Type, Authorization");
      res.header("Access-Control-Allow-Credentials", "true");
      if (req.method === "OPTIONS") {
        res.sendStatus(200);
      } else {
        express.json()(req, res, next);
      }
    }
  }
);

const port = process.env.SERVER_PORT || 8080;

app.use(expressLayouts);
app.set("views", path.join(__dirname, "views"));
app.set("layout", "./layout");
app.set("view engine", "ejs");

app.use(express.static(path.join(__dirname, "public")));

routes.register(app);

// Run 'report usage' function every day at midnight
const job = new CronJob(
  "0 0 * * *",
  async () => {
    await StripeBillingService.reportUsageToStripe();
  },
  null,
  true,
  "Europe/London"
);

app.listen(port, () => {
  // tslint:disable-next-line:no-console
  console.log(`server started at http://localhost:${port}`);
});
