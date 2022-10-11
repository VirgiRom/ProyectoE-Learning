trigger UnitResponse on User_Unit__c (before update) {
    UnitResponseTrigger.CheckUpdate(Trigger.new,Trigger.oldMap);
}