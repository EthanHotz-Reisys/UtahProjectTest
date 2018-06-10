public with sharing class PublicAnnouncementsCtrl{
      public boolean isInternal{get;set;}
    
    public PublicAnnouncementsCtrl(){
         if(Network.getNetworkId() == null){
             isInternal = true;
         }else{
             isInternal = false;
         }
             
    }
}