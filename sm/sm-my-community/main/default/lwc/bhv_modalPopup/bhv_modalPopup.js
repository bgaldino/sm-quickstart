import { LightningElement, api } from "lwc";

const HEADER_CSS_CLASS = "slds-modal__header";
const POPUP_HEADER_CSS_CLASS = "sb-popup__header";
const FOOTER_CSS_CLASS = "slds-modal__footer";
const BORDERLESS_CSS_CLASS = " no-borders";
const MODAL_CONTAINER_CSS_CLASS = "slds-modal__container";
const FULL_SCREEN_CONTAINER_CSS_CLASS = " full-screen-modal-container";
const MODAL_CONTENT_CSS_CLASS = "slds-modal__content sb-text_body";
const FULL_SCREEN_CONTENT_CSS_CLASS = " full-screen-modal-content";
const CLOSE_ICON_CSS_CLASS = "close-icon";
const INSIDE_CLOSE_ICON_CSS_CLASS = " close-icon-inside-container";
const OUTSIDE_CLOSE_ICON_CSS_CLASS = " close-icon-outside-container";
const MENU_ITEM_ROW_HEIGHT = 56;
const EMPTY_MENU_HEIGHT = 200;

export default class Bhv_modalPopup extends LightningElement {
  labels = { BHV_Close: "Close" };
  // Whether the popup is open or not
  _isOpen = false;

  // Pop up menu variant
  menu;
  popup;
  _isPopup = false;
  _isMenu = false;
  _menuItems = [];

  // Exposed properties
  @api fullScreen = false;
  @api hideCloseIcon = false;
  @api showCloseButton = false;
  @api closeButtonLabel = this.labels.BHV_Close;
  @api closeIconSize = "medium"; //this is no longer in use
  @api closeIconOutsideContainer = false;

  @api get menuItems() {
    return this._menuItems;
  }
  set menuItems(aMenuItems) {
    this.menuOffset = MENU_ITEM_ROW_HEIGHT * aMenuItems.length;
    this.menuOffset += EMPTY_MENU_HEIGHT;
    this._menuItems = aMenuItems;
  }

  @api get isPopup() {
    return this._isPopup;
  }
  set isPopup(aBoolean) {
    this._isPopup = aBoolean;
  }

  @api get isMenu() {
    return this._isMenu;
  }
  set isMenu(aBoolean) {
    this._isMenu = aBoolean;
  }

  /*
   * Return whether the popup is open or not
   */
  @api
  get isOpen() {
    return this._isOpen;
  }

  /*
   * Exposed attribute to open the popup
   */
  @api open() {
    this._isOpen = true;
    this.delay(25).then(() => {
      const backdrop = this.template.querySelector(".js-backdrop");
      backdrop.classList.add("slds-backdrop_open");
      if (this.getIsModal) {
        const modal = this.template.querySelector(".js-modal");
        modal.classList.add("slds-fade-in-open");
      }
    });
  }

  /*
   * Exposed attribute to close the popup
   */
  @api close() {
    if (this.getIsModal) {
      this.delay(50).then(() => {
        const backdrop = this.template.querySelector(".js-backdrop");
        const modal = this.template.querySelector(".js-modal");
        modal.classList.remove("slds-fade-in-open");
        backdrop.classList.remove("slds-backdrop_open");
        this._isOpen = false;
      });
    } else {
      this._isOpen = false;
    }
  }

  renderedCallback() {
    if (this.getIsPopup) {
      this.popup = this.template.querySelector(".js-popup");
      // position the menu off the bottom of the screen
      if (this.popup) {
        this.popup.style.transform = `translate3d(0, ${this.getAnimationDistance}px, 0)`;
        this.delay(0).then(() => {
          this.popup.style.transition = "transform 0.2s ease";
          this.delay(100).then(() => {
            this.popup.style.transform = "translate3d(0, 0, 0)";
          });
        });
      }
    }
  }

  menuSelect(e) {
    e.preventDefault();
    e.stopPropagation();
    const menuSelectEvent = new CustomEvent(EVENT_MORE_MENU_ITEM_SELECTED, {
      detail: {
        menuItemIndex: e.currentTarget.dataset.menuItemIndex
      }
    });
    this.dispatchEvent(menuSelectEvent);
    this.popUpClose();
  }

  @api popUpClose() {
    this.popup.style.transform = `translate3d(0, ${this.getAnimationDistance}px, 0)`;
    this.delay(200).then(() => {
      this.close();
    });
  }

  autoClose(e) {
    e.preventDefault();
    e.stopPropagation();
    if (this.getIsPopup) {
      this.popUpClose();
    } else {
      this.close();
    }
  }

  get getIsModal() {
    return !this._isMenu && !this._isPopup;
  }
  get getIsPopup() {
    return !this.getIsModal;
  }
  get getAnimationDistance() {
    if (this._isMenu) {
      return this.menuOffset;
    }
    return this.popup.offsetHeight;
  }

  get headerCssClass() {
    if (this._isPopup) {
      return `${POPUP_HEADER_CSS_CLASS} ${HEADER_CSS_CLASS}`;
    }
    return HEADER_CSS_CLASS + (this.fullScreen ? BORDERLESS_CSS_CLASS : "");
  }

  get footerCssClass() {
    return FOOTER_CSS_CLASS + (this.fullScreen ? BORDERLESS_CSS_CLASS : "");
  }

  get closeIconCssClass() {
    if (this._isPopup) {
      return `${CLOSE_ICON_CSS_CLASS} sb-popup__close-icon`;
    }
    return (
      CLOSE_ICON_CSS_CLASS +
      (this.closeIconOutsideContainer
        ? OUTSIDE_CLOSE_ICON_CSS_CLASS
        : INSIDE_CLOSE_ICON_CSS_CLASS)
    );
  }

  get modalContainerCssClass() {
    return (
      MODAL_CONTAINER_CSS_CLASS +
      (this.fullScreen ? FULL_SCREEN_CONTAINER_CSS_CLASS : "")
    );
  }

  get modalContentCssClass() {
    return (
      MODAL_CONTENT_CSS_CLASS +
      (this.fullScreen ? FULL_SCREEN_CONTENT_CSS_CLASS : "")
    );
  }

  delay(ms) {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    return new Promise((resolve) => window.setTimeout(resolve, ms));
  }
}
