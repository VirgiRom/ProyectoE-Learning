import { LightningElement, api } from 'lwc';

const TILE_WRAPPER_SELECTED_CLASS = 'tile-wrapper selected custom-box slds-box slds-p-around_medium'
const TILE_WRAPPER_UNSELECTED_CLASS = 'tile-wrapper custom-box slds-box slds-p-around_medium'

export default class answerView extends LightningElement {
    @api answer;
    @api question;
    @api optionSelected;
    optionId;

    renderedCallback() {

        /* console.log(JSON.stringify(this.answer) + 'answer test'); */
    }

    handleClick() {
        let optionId = this.answer.Id;
        let questionId = this.question.Id
        console.log(this.question + 'questionnn datarecord')
        const response = new CustomEvent("optionselect", {
            detail: {
                questionId,
                optionId

            }
        })
        this.dispatchEvent(response);
    }

    get tileClass() {
        if (this.optionSelected.includes(this.answer.Id)) {
            return TILE_WRAPPER_SELECTED_CLASS
        } else {
            return TILE_WRAPPER_UNSELECTED_CLASS
        }
    }

}