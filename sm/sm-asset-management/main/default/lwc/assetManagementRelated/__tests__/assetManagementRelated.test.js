import { createElement } from "lwc";
import AssetManagementRelated from "c/assetManagementRelated";
import getAssetsByAccount from "@salesforce/apex/AssetManagementController.getAssetsByAccount";
import renewAssets from "@salesforce/apex/AssetManagementController.renewAssets";

const getMockAssets = require("./data/getAssetList.json");
const selectedRows = [
    {
        "asset": {
          "CurrentQuantity": 0,
          "Id": "02iRO0000008EkoYAE",
          "AccountId": "001RO0000048aySYAQ",
          "Product2Id": "01tRO000000Yuy9YAC",
          "Name": "Software Suite - Incl"
        },
        "assetId": "02iRO0000008EkoYAE",
        "name": "Software Suite - Incl",
        "recordURL": "testing.salesforce.com/02iRO0000008EkoYAE",
    }
];

const APEX_SUCCESS = "";

jest.mock(
    "@salesforce/apex/AssetManagementController.getAssetsByAccount",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/AssetManagementController.renewAssets",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);
jest.mock(
    "@salesforce/apex/AssetManagementController.cancelAssets",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    "@salesforce/apex/AssetManagementController.amendAssets",
    () => {
        const { createApexTestWireAdapter } = require("@salesforce/sfdx-lwc-jest");
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe("c-asset-management-related", () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    //Helper method to wait until the microtask queue is empty.
    async function flushPromises() {
        return Promise.resolve();
    }

    it("renders two rows in the lightning datatable", async () => {
        const element = createElement("c-asset-management-related", {
            is: AssetManagementRelated
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getAssetsByAccount.emit(getMockAssets);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const tableEl = element.shadowRoot.querySelector("lightning-tree-grid");

        //Validate the datatable is populated with correct number of records
        expect(tableEl.data.length).toBe(getMockAssets.length);
    });

    it("verify renew button is disabled if no row is selected", async () => {
        // Create initial element
        const element = createElement("c-asset-management-related", {
            is: AssetManagementRelated
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getAssetsByAccount.emit(getMockAssets);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const buttonEl = element.shadowRoot.querySelector("lightning-button");

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //valdiate Renew button is disabled when no rows are selected
        expect(buttonEl.disabled).toBe(true);
    });

    it("verify renew button is enabled when a user selects at-least 1 row", async () => {
        const element = createElement("c-asset-management-related", {
            is: AssetManagementRelated
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getAssetsByAccount.emit(getMockAssets);

        const buttonEl = element.shadowRoot.querySelector("lightning-button");
        const tableEl = element.shadowRoot.querySelector("lightning-tree-grid");
        tableEl.dispatchEvent(
            new CustomEvent("rowselection", {
                detail: {
                    selectedRows: selectedRows
                }
            })
        );

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //valdiate Renew button is enabled when at-least 1 row is selected
        expect(buttonEl.disabled).toBe(false);
    });

    it("verify cancel button is disbled when atleast 1 row is selected and date is not populated", async () => {
        const element = createElement("c-asset-management-related", {
            is: AssetManagementRelated
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getAssetsByAccount.emit(getMockAssets);

        const tableEl = element.shadowRoot.querySelector("lightning-tree-grid");
        tableEl.dispatchEvent(
            new CustomEvent("rowselection", {
                detail: {
                    selectedRows: selectedRows
                }
            })
        );
        await flushPromises();
        const buttonEl = element.shadowRoot.querySelector(
            "lightning-button[data-id=CancelAction]"
        );
        expect(buttonEl.disabled).toBe(false);
        buttonEl.click();
        await flushPromises();
        const dateEl = element.shadowRoot.querySelector("lightning-input");
        const cancelButton = element.shadowRoot.querySelector(
            "lightning-button[data-id=CancelAsset]"
        );
        dateEl.value = new Date().toJSON();
        dateEl.dispatchEvent(new CustomEvent("change"));
        // Wait for any asynchronous DOM updates
        await flushPromises();
        //valdiate Renew button is disable when at-least 1 row is selected and date is null
        expect(cancelButton.disabled).toBe(false);
    });

    it("verify renew button is clicked after selected a row", async () => {
        renewAssets.mockResolvedValue(APEX_SUCCESS);
        const element = createElement("c-asset-management-related", {
            is: AssetManagementRelated
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getAssetsByAccount.emit(getMockAssets);

        const tableEl = element.shadowRoot.querySelector("lightning-tree-grid");
        tableEl.dispatchEvent(
            new CustomEvent("rowselection", {
                detail: {
                    selectedRows: selectedRows
                }
            })
        );
        await flushPromises();
        const buttonEl = element.shadowRoot.querySelector("lightning-button[data-id=Renew]");
        
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //valdiate Renew button is enabled when at-least 1 row is selected
        expect(buttonEl.disabled).toBe(false);
        //validate the renew action is invoked
        expect(renewAssets.mock.calls.length).toBe(1);
    });
});
