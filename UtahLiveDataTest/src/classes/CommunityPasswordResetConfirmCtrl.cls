public with sharing class CommunityPasswordResetConfirmCtrl {

    public PageReference loginPage() {
        String ns = AppUtils.getNamespacePrefix();
        if(Network.getNetworkId() == null){ // Internal Site user
            return new PageReference('/' + ns + 'InternalLogin');
        }else{    // External Community user
            return new PageReference('/' + ns + 'ApplicantLogin4');
        }
    }

}