public with sharing class UnitResponseTrigger {
    
    public static void checkUpdate(List<User_Unit__c> userUnitList, Map<Id,User_Unit__c> mapUnit){

        List <User_Unit__c> listFilter = new List <User_Unit__c>();
        for(user_Unit__c  resultFilter : userUnitList){
            if(ResultFilter.Status__C == 'Answered' && MapUnit.get(ResultFilter.id).Status__c == 'draft'){
            listFilter.add(ResultFilter);
        }
    }
    CheckAnswered(listFilter);
}
    
    Public static void checkAnswered (List<user_Unit__c> listFilter){
        map <id, user_Unit__c> mapfilter = new map <id, user_Unit__c> ([SELECT id, unit__r.Points__c, (SELECT Answer__r.Is_Correct__c From User_Answers__r)
                                                                        FROM User_Unit__c WHERE ID in: listfilter]);
            for (user_Unit__c filtro : listFilter){
                integer contador =0;
                for (user_Answer__c respuestas : Mapfilter.get(Filtro.id).User_Answers__r) {                       
                    if (respuestas.Answer__r.Is_Correct__c == true){
                        contador ++;
                    }}
                if(contador == Mapfilter.get(Filtro.id).User_Answers__r.size()){
                    Filtro.status__C = 'Success';    
                            if(Filtro.Try_number__c == 1){
                                   Filtro.points__c = Mapfilter.get(Filtro.id).unit__r.points__c;
                            }else if(Filtro.Try_number__c == 2){
                                  Filtro.points__c = Mapfilter.get(Filtro.id).unit__r.points__c/2;
                            }else
                            {Filtro.points__c = Mapfilter.get(Filtro.id).unit__r.points__c/4;
                                        }
                }else{
                    Filtro.status__C= 'Fail';
                    }
                
        }
    }
}

