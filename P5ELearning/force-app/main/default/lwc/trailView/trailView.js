import { api, LightningElement, wire } from 'lwc';
import getTrail from '@salesforce/apex/JSController.getTrail';
export default class TrailView extends LightningElement {
    @api recordId;
    name;
    time;
    description;
    points;
    progress;
    error = undefined;
    modulos;
    checkmodule;
    checkunit;

    @wire(getTrail, { trailId: '$recordId' })
    trail(Result) {
        const { data, error } = Result;
        if (data) {
            console.log(data);
            this.name = data.trail.Name;
            this.time = data.trail.Time__c;
            this.description = data.trail.Description__c;
            this.points = data.trail.Points__c;
            this.progress = Math.round((data.passedUnitIds.length/data.trail.CantidadUnidades__c)*100);
            // this.progress =  Number.parseFloat((data.passedUnitIds.length/data.trail.CantidadUnidades__c)*100).toFixed(0); 
            this.modulos = data.modules;
            this.checkmodule = data.passedModuleIds;
            this.checkunit = data.passedUnitIds;
        } else if (error) {
            this.trailWrapper = undefined;
            this.error = error;
        }
    }
}    


