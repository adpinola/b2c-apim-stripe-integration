import { DefaultAzureCredential } from "@azure/identity";
import { ApiManagementClient } from "@azure/arm-apimanagement";
import { ProductGetResponse, ProductListByServiceResponse, ReportRecordContract, SubscriptionCreateOrUpdateResponse, SubscriptionGetResponse, SubscriptionListResponse, SubscriptionListSecretsResponse, SubscriptionState, UserCreateOrUpdateResponse, UserGetResponse, UserGetSharedAccessTokenResponse } from "@azure/arm-apimanagement/esm/models";
import { Utils } from "../utils";
import fetch from "node-fetch";
import { Guid } from 'js-guid';

export class ApimService {

    initialized = false;
    managementClient: ApiManagementClient;

    subscriptionId : string = process.env.APIM_SERVICE_AZURE_SUBSCRIPTION_ID;
    resourceGroupName : string = process.env.APIM_SERVICE_AZURE_RESOURCE_GROUP_NAME;
    serviceName : string = process.env.APIM_SERVICE_NAME;

    /** Get the list of products for the APIM service */
    public async getProducts() : Promise<ProductListByServiceResponse> {
        await this.initialize();

        return await this.managementClient.product.listByService(this.resourceGroupName, this.serviceName);
    }

    /** Get the list of subscriptions for the APIM service */
    public async getSubscriptions() : Promise<SubscriptionListResponse> {
        await this.initialize();

        return await this.managementClient.subscription.list(this.resourceGroupName, this.serviceName);
    }

    /** Get a single product by product ID for the APIM service */
    public async getProduct(productId: string) : Promise<ProductGetResponse> {
        await this.initialize();

        return await this.managementClient.product.get(this.resourceGroupName, this.serviceName, productId);
    }

    /** Get a user by ID */
    public async getUser(userId: string) : Promise<UserGetResponse> {
        await this.initialize();

        return await this.managementClient.user.get(this.resourceGroupName, this.serviceName, userId);
    }

    /** Get a subscription by ID */
    public async getSubscription(sid: string) : Promise<SubscriptionGetResponse> {
        await this.initialize();

        return await this.managementClient.subscription.get(this.resourceGroupName, this.serviceName, sid);
    }

    /** Get a subscription by ID */
    public async getSubscriptionKeys(sid: string) : Promise<SubscriptionListSecretsResponse> {
        await this.initialize();

        return await this.managementClient.subscription.listSecrets(this.resourceGroupName, this.serviceName, sid)
    }

    /** Create a new subscription to a product for a user */
    public async createSubscription(productId: string, subscriptionName: string) : Promise<SubscriptionCreateOrUpdateResponse> {
        await this.initialize();
        const subscriptionId = `${subscriptionName}-${productId}`;

        return await this.managementClient.subscription.createOrUpdate(
            this.resourceGroupName,
            this.serviceName,
            subscriptionId,
            {
                displayName: subscriptionId,
                scope: `/products/${productId}`,
                state: "active",
            }
        );
    }

    /** Get the usage for a particular subscription between two dates */
    public async getUsage(sid: string, to: Date, from?: Date) : Promise<ReportRecordContract> {
        await this.initialize();
        const filter = `timestamp ge datetime'${from ? from.toISOString() : new Date('2000-01-01').toISOString()}' and timestamp le datetime'${to.toISOString()}' and subscriptionId eq '${sid}'`;
        const report = await this.managementClient.reports.listBySubscription(this.resourceGroupName, this.serviceName, filter);

        return report[0];
    }

    /** List the subscriptions for a user */
    public async getUserSubscriptions(userId: string) : Promise<SubscriptionListResponse> {
        await this.initialize();

        return await this.managementClient.userSubscription.list(this.resourceGroupName, this.serviceName, userId);
    }

    /** Update the state of a subscription (for the API keys related to a subscription to work, that subscription must be in an active state) */
    public async updateSubscriptionState(sid: string, state : SubscriptionState) {
        await this.initialize();

        return await this.managementClient.subscription.update(this.resourceGroupName, this.serviceName, sid, { state }, "*");
    }

    /** Get a shared access token for the user */
    public async getSharedAccessToken(userId: string) : Promise<UserGetSharedAccessTokenResponse> {
        await this.initialize();

        const expiry = new Date();
        expiry.setDate(expiry.getDate() + 1);

        return await this.managementClient.user.getSharedAccessToken(this.resourceGroupName, this.serviceName, userId, { expiry, keyType: "primary" });
    }

    /** Create a new user */
    public async createUser(email: string, password: string, firstName: string, lastName: string) : Promise<UserCreateOrUpdateResponse> {
        await this.initialize();

        return await this.managementClient.user.createOrUpdate(
            this.resourceGroupName,
            this.serviceName,
            Guid.newGuid().toString(),
            {
                email,
                firstName,
                lastName,
                password
            }
        );
    }

    /** Authenticate a user using basic authentication */
    public static async authenticateUser(email: string, password: string): Promise<any> {
        try {

            const credentials = `Basic ${Buffer.from(`${email}:${password}`).toString('base64')}`;
            const managementApiUrl = Utils.ensureUrlArmified(process.env.APIM_MANAGEMENT_URL)
            const url = `${managementApiUrl}/identity?api-version=2019-12-01`
            const response = await fetch(url, { method: "GET", headers: { Authorization: credentials } });
            const sasToken = response.headers.get("Ocp-Apim-Sas-Token");
            const identity = await response.json() as { id: string };

            return {
                authenticated: true,
                sasToken,
                userId: identity.id
            };
        }
        catch (error) {
            return { authenticated: false };
        }
    }

    private async initialize() {
        if (!this.initialized) {
            const client = new ApiManagementClient(new DefaultAzureCredential(), this.subscriptionId);
            this.managementClient = client
            this.initialized = true;
        }
    }
}