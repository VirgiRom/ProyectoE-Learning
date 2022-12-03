public with sharing class UnitService {
  @AuraEnabled (cacheable=false)
  public static Boolean registerUserAnswer(Id unitId, String jsonAnswer) {
    Savepoint sp = Database.setSavepoint();
    Boolean verify = false;
    try {
system.debug('funcionara?');
      Unit__c unit = [
                      SELECT  Module__c, 
                      ( SELECT Id,  
                      Try_number__c 
                      FROM User_Units__r 
                      WHERE User_Module__r.user__c = :UserInfo.getUserId()                 
                      ORDER BY Try_number__c 
                      DESC LIMIT 1),               
                      (SELECT Id, 
                      Name 
                      FROM Questions__r)
                      FROM Unit__c
                      WHERE Id = :unitId
                      WITH SECURITY_ENFORCED
                     ];
system.debug('funcionara1?');

User_Module__c Prueba;
try{
                       Prueba = [
                                SELECT Id 
                                FROM User_Module__c 
                                WHERE Module__c = :unit.Module__c 
                                AND User__c = :UserInfo.getUserId()
                                AND Status__c = 'In Progress'
                                WITH SECURITY_ENFORCED
                                ];
}catch (Exception e){
                      Prueba = new  User_Module__c(
                              User__c = userInfo.getUserId(),
                              Module__c = unit.Module__c,
                              Status__c = 'In Progress');
system.debug('funcionara2?');
                      insert Prueba;
}                          

      User_Unit__c unitResp = new User_Unit__c(
        Unit__c = unitId,
        User_Module__c = Prueba.Id,
        Status__c = 'Draft',
        User__c = UserInfo.getUserId()
      );
      unitResp.Try_number__c = !unit.User_Units__r.isEmpty()
        ? unit.User_Units__r[0].Try_number__c + 1
        : 1;
      insert UnitResp;
      Map<Id, Id> answerMap = (Map<Id, Id>) JSON.deserialize(
        jsonAnswer,
        Map<Id, Id>.class
      );
      List<User_Answer__c> questionRespList = new List<User_Answer__c>();
      
      for (Question__c question : unit.Questions__r) {
        if (answerMap.containsKey(question.Id)) {
          User_Answer__c questionResp = new User_Answer__c(
            Question__c = question.iD,
            User_Unit__c = unitResp.Id,
            Answer__c = answerMap.get(question.Id)
          );
          questionRespList.add(questionResp);
        } else {
         
          System.debug('La pregunta no fue respondida y es requerida');
        }
      }

      insert questionRespList;

      unitResp.Status__c = 'Answered';

      update unitResp;

      verify = true;
    } catch (Exception e) {
      Database.rollback(sp);
      throw e;
    }
    return verify;
  }
  public class TrailWrapper{
    //Configuracion
    @AuraEnabled 
    public Trail__c trail; //Registro de Trail solicitado
    @AuraEnabled 
    public List<Module__c> modules; //Módulos con Unidades relacionadas
    
    //Transaccional
    @AuraEnabled 
    public List<Id> passedModuleIds; //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
    @AuraEnabled 
    public List<Id> passedUnitIds; //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
    @AuraEnabled 
    public Double progressTrail; //Porcentaje de progreso del Alumno en el Trail

    public TrailWrapper (
                        Trail__c trail, 
                        List<Module__c> modules,
                        List<Id> passedModuleIds, 
                        List<Id> passedUnitIds){
        this.trail = trail;
        this.modules = modules;
        this.passedModuleIds = passedModuleIds;
        this.passedUnitIds = passedUnitIds;
    }
}
   
		public TrailWrapper getTrailWrapper(Id trailId){
		
        //List<Module__c> modules = (getModules(trailId));
        
       // List<Id> completedModules = (getModuleIdsCompleted(trailId, modules));
        
        //List<Id> completedUnits = (getUnitIdsCompleted(trailId, completedModules));
        
        TrailWrapper trailWrap = new TrailWrapper([
                                                  SELECT Name, 
                                                  Description__c, 
                                                  Points__c,
                                                  Time__c,
                                                  CantidadUnidades__c
                                                  FROM Trail__c 
                                                  WHERE Id =: trailId
                                                  WITH SECURITY_ENFORCED
                                                  ],
         getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));
        
        return trailWrap;
    }

    private static List<Module__c> getModules(Id trailId){

        //Busco modulos relacionados al trailId recibido como parametro
        List<Trail_Module__c> trailModules = [
                                            SELECT Module__c 
                                            FROM Trail_Module__c 
                                            WHERE Trail__c =: trailId
                                            WITH SECURITY_ENFORCED
                                            ];
        //Guardo y retorno los ids de los modulos relacionados al trailId
        Set<Id> moduleIds = new Set<Id>();
        for(Trail_Module__c trailModule : trailModules){
            moduleIds.add(trailModule.Module__c);
        }

        return [
          SELECT Name, 
          Description__c, 
          Points__c, 
          Time__c, 
          (SELECT Name, description__c, Points__c, Time__c FROM Units__r) 
          FROM Module__c 
          WHERE Id in : moduleIds
          WITH SECURITY_ENFORCED
          ];
    }

    private static List<Id> getModuleIdsCompleted(Id trailId){

        //Buscar los modulos completados relacionados al trailId
        List<User_Module__c> moduleResponses = [
                                              SELECT Module__c 
                                              FROM User_Module__c 
                                              WHERE Status__c = 'Completed' 
                                              AND Module__c in : getModules(trailId) 
                                              AND User__c =: Userinfo.getUserId()
                                              WITH SECURITY_ENFORCED
                                              ];

        //Guardo y retorno los ids de los modulos completados
        Set<Id> completedModuleIds = new Set<Id>();
        for(User_Module__c moduleResp : moduleResponses){
            completedModuleIds.add(moduleResp.Module__c);
        }

        return  new List <Id>(completedModuleIds);
    }
    private static List<Id> getUnitIdsCompleted(Id trailId){

        // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	  List<User_Unit__c> unitResponses = [
                                      SELECT Unit__c 
                                      FROM User_Unit__c 
                                      WHERE Status__c = 'Success' 
                                      AND User__c =: Userinfo.getUserId() 
                                      AND Unit__r.Module__c in : getModules(trailId)
                                      WITH SECURITY_ENFORCED
                                      ];
		// !!!!!!!!!!!        
        //Guardo el id de las unitsCompleted
        Set<Id> completedUnitIds = new Set<Id>();
        for(	User_Unit__c unitResp : unitResponses){
            completedUnitIds.add(unitResp.Unit__c);
        }

        return  new List <Id>(completedUnitIds);
    }
    @AuraEnabled (cacheable=true)
    public static UnitWrapper getUnitWrapper(Id unitId){


        Unit__c unit = [
                        SELECT Name, 	
                        description__c,
                        Points__c,
                        Time__c, 
                        (SELECT id, 	description__c FROM Questions__r) 
                        FROM Unit__c 
                        WHERE Id =: unitId
                        WITH SECURITY_ENFORCED
                        ];

        List<Question__c> questions = [
                                      SELECT 
                                      id,
                                      Name,
                                      Description__c,
                                      (SELECT id, Name, Description__c,Is_Correct__c FROM Answers__r) 
                                      FROM question__c 
                                      WHERE Unit__c =: unitId
                                      WITH SECURITY_ENFORCED
                                      ];

        UnitWrapper unitWrap = new UnitWrapper(unit, questions);
        return unitWrap;
    }
    
    public class UnitWrapper {
        @AuraEnabled    
        public Unit__c unit; //Unidad solicitada
        @AuraEnabled 
        public List <Question__c> questions; // Lista de preguntas de la unidad

        public UnitWrapper (Unit__c unit, List<Question__c> questions){
            this.unit = unit;
            this.questions = questions;
        }
    }
}