public without sharing class ReviewHelper{
    
    @future
    public static void updateReviewStepScoreAndRank(Set<Id> revIdSet){
        Map<Id,Decimal> reviewStepTotal = new Map<Id,Decimal>(); 
        Set<Id> appPreAppIds = new Set<Id>();
        Map<Id,List<Review__c>> appIdToReviewList = new Map<Id,List<Review__c>>();
        Set<Id> revStepIdSet = new Set<Id>();
         
        List<Review__c> revs = [select ReviewPanel__r.ReviewStep__c,Status__c From Review__c Where id IN :revIdSet];
        for(Review__c rev : revs ){
            revStepIdSet .add(rev.ReviewPanel__r.ReviewStep__c);
        }
        
        List<Review__c> reviews = [select Application__c,PreApplication__c,SummaryScore__c,Status__c,
            ReviewPanel__r.ReviewStep__c from Review__c where ReviewPanel__r.ReviewStep__c in :revStepIdSet
            AND Status__c = 'Review Completed' AND ReviewPanel__r.ExcludeFromScoring__c = false];
        
        for(Review__c review : reviews){
            system.debug('review  >>>>'+review );

            if(review.Application__c != null){
                appPreAppIds.add(review.Application__c);
                List<Review__c> revId = appIdToReviewList.get(review.Application__c);
                if(revId == null){
                    revId = new List<Review__c>();
                }
                revId.add(review);
                appIdToReviewList.put(review.Application__c, revId);
            }else{
                appPreAppIds.add(review.PreApplication__c);
                List<Review__c> revId = appIdToReviewList.get(review.Application__c);
                if(revId == null){
                    revId = new List<Review__c>();
                }
                revId.add(review);
                appIdToReviewList.put(review.PreApplication__c, revId);
            }
        }
        if(revStepIdSet.size() > 0){
            system.debug('revStepIdSet >>>>'+revStepIdSet);
            String query = 'Select ';
            query += 'id,TotalScore__c,ReviewStep__c,Application__c,PreApplication__c from ReviewStepApplication__c where ReviewStep__c = :revStepIdSet and (Application__c in :appPreAppIds OR PreApplication__c in :appPreAppIds)';
            List<ReviewStepApplication__c> revStepApp = Database.query(query);
            Decimal Score = 0;
            Map<Id, Integer> rsaIdToReviewCount = new Map<Id, Integer>();
            if(revStepApp.size() > 0){
                for(ReviewStepApplication__c rsa : revStepApp){
                    system.debug('rsa  >>>>'+rsa );
                    List<Review__c> revList = new List<Review__c>();
                    if(rsa.Application__c!=null){
                        revList = appIdToReviewList.get(rsa.Application__c);
                    }else{
                        revList = appIdToReviewList.get(rsa.PreApplication__c);
                    }
                    Decimal total = 0;
                    for(Review__c rev : revList ){
                        if(rsa.ReviewStep__c == rev.ReviewPanel__r.ReviewStep__c){
                            system.debug('rev  >>>>'+rev );
                            if(rev.SummaryScore__c != null){
                                if(rsa.totalScore__c == null){
                                    rsa.totalScore__c = 0;
                                }
                                system.debug('rsa.totalScore__c ----'+rsa.totalScore__c);
                                system.debug('rev.SummaryScore__c ----'+rev.SummaryScore__c);
                                total += rev.SummaryScore__c;
                                system.debug('rsa.totalScore__c ----'+rsa.totalScore__c);
                            }  
                        }
                        if(rev.Application__c != null && rsa.Application__c != null && rev.Application__c == rsa.Application__c && rev.Status__c!='Review Declined'){
                            Integer revCount = rsaIdToReviewCount.get(rsa.Id);
                            if(revCount == null){
                                revCount = 0;
                            }
                            rsaIdToReviewCount.put(rsa.Id, revCount+1);
                        }
                    }
                    rsa.TotalScore__c = total;
                    Integer noOfReviews = rsaIdToReviewCount.get(rsa.Id);
                    if(noOfReviews == null){
                        noOfReviews = 0;
                    }
                    rsa.NumberOfReviews__c = noOfReviews;
                    //if(noOfReviews > 0 && rsa.TotalScore__c != null && rsa.TotalScore__c > 0){
                    //    rsa.AverageScore__c = rsa.TotalScore__c / noOfReviews;
                    //}
                }
                update revStepApp;
                
                // code to calculate the ApplicationRank__c
                List<ReviewStepApplication__c> rsaList = [Select ApplicationRank__c, Application__c, PreApplication__c, 
                                                          ReviewStep__c, totalScore__c, NumberOfReviews__c, AverageScore__c
                                                          From ReviewStepApplication__c 
                                                          Where ReviewStep__c IN :revStepIdSet AND AverageScore__c != null 
                                                          Order by AverageScore__c DESC]; // Id IN : revStepApp Order by TotalScore__c
                Integer rankCounter = 1;
                Set<Id> appIdSet = new Set<Id>();
                Set<Id> preAppIdSet = new Set<Id>();
                
                ReviewStepApplication__c oldRsa;
                for(ReviewStepApplication__c rsa : rsaList){
                    if(rsa.AverageScore__c != null){
                        if(oldRsa != null){
                            if(oldRsa.AverageScore__c > rsa.AverageScore__c){
                                rankCounter++;
                            }
                        }
                        rsa.ApplicationRank__c = rankCounter;
                        oldRsa = rsa;
                    }
                }
                
                update rsaList;
                
                // code to calculate the score and rank at application record.
                List<Application__c> appList = new List<Application__c>();
                for(ReviewStepApplication__c rsa : rsaList){
                    Application__c app = new Application__c(Id = rsa.Application__c);
                    app.ApplicationRank__c = rsa.ApplicationRank__c;
                    app.TotalScore__c = rsa.TotalScore__c;
                    app.NumberOfReviews__c = rsa.NumberOfReviews__c;
                    app.AverageScore__c = rsa.AverageScore__c;
                    appList.add(app);
                }
                SystemContextMethodsHelper scHelper = new SystemContextMethodsHelper();
                scHelper.updateApplications(appList);
                
                update rsaList;
            }
        }
    }
    
    public static void updateReviewStatusHTML(Set<Id> reviewIds, Boolean isDelete){
        Map<Id, String> appIdToJsonMap = new Map<Id, String>();
        List<Id> revStepIdList = new List<Id>();
        List<Id> appPreAppIdList = new List<Id>();
        
        List<Review__c> reviewList = [Select Id, ReviewPanel__r.ReviewStep__c, PanelUser__r.Reviewer__r.Name,
                                        ReviewPanel__r.GroupName__c, PreApplication__c, Application__c, Status__c 
                                        From Review__c Where Id IN : reviewIds];
        
        for(Review__c review : reviewList){
            Id appId;
            if(review.Application__c != null){
                appId = review.Application__c;
            }else{
                appId = review.PreApplication__c;
            }
            String revStatusJSON = review.Id + ':' + review.Status__c + '#';
            String jsonString = appIdToJsonMap.get(appId);
            if(!String.isEmpty(jsonString)){
                jsonString += revStatusJSON; 
            }else{
                jsonString = revStatusJSON;
            }
            appIdToJsonMap.put(appId, jsonString);
            revStepIdList.add(review.ReviewPanel__r.ReviewStep__c);
            appPreAppIdList.add(appId);
        }
        system.debug('appIdToJsonMap ---'+appIdToJsonMap);
        updateReviewStatusOnStepApplication(revStepIdList, appPreAppIdList, appIdToJsonMap, isDelete);
    }
    
    /* Update the Review Status on RSA obejct */
    @future
    public static void updateReviewStatusOnStepApplication(List<Id> revStepIdList, List<Id> appPreAppIdList, Map<Id, String> appIdToJsonMap, Boolean isDelete){
        Map<Id, String> revIdToStatus = new Map<Id, String>();
        Map<Id, String> revIdToRecommendation = new Map<Id, String>();
        Map<Id, String> revIdToReviewer = new Map<Id, String>();    
        Set<Id> reviewIdSet = new Set<Id>();
        Map<Id, Id> revIdToStepAppIdMap = new Map<Id, Id>();
        Map<Id, String> stepAppIdToHTMLMap = new Map<Id, String>();

        List<ReviewStepApplication__c> rsaList = [Select id, ReviewStatus__c, ReviewStatusJsonString__c, Application__c, PreApplication__c 
                                                    From ReviewStepApplication__c 
                                                    Where ReviewStep__c IN : revStepIdList
                                                    AND (Application__c IN : appPreAppIdList OR PreApplication__c IN : appPreAppIdList)];
        
        for(ReviewStepApplication__c rsa : rsaList){
            String revStatusJSON = '';
            if(rsa.Application__c != null){
                revStatusJSON = appIdToJsonMap.get(rsa.Application__c);
            }else{
                revStatusJSON = appIdToJsonMap.get(rsa.PreApplication__c);
            }
            system.debug('rsa.ReviewStatusJsonString__c ---'+rsa.ReviewStatusJsonString__c);
            if(rsa.ReviewStatusJsonString__c != null){
                rsa.ReviewStatusJsonString__c = generateJSON(rsa.ReviewStatusJsonString__c, revStatusJSON, isDelete);
            }else{
                rsa.ReviewStatusJsonString__c = revStatusJSON;
            }
            system.debug('rsa.ReviewStatusJsonString__c ---'+rsa.ReviewStatusJsonString__c);
            Set<Id> revIdSet = getAllReviewIds(rsa.ReviewStatusJsonString__c);
            for(Id revId : revIdSet){
                revIdToStepAppIdMap.put(revId, rsa.Id);
            }
            reviewIdSet.addAll(revIdSet);
            system.debug('reviewIdSet ----'+reviewIdSet);
        }
        
        List<Review__c> allReviewsList = [Select Id, Recommendation__c, Status__c,Reviewer__r.Name,
                            PanelUser__r.Reviewer__r.Name, ReviewPanel__r.GroupName__c,OwnerId,Owner.Name
                                    From Review__c Where Id IN : reviewIdSet  ]; // Id IN : reviewIdSet -- ReviewPanel__r.ReviewStep__c IN :revStepIdList
        Map<Id, Boolean> reviewIdToCompletedFlag = new Map<Id, Boolean>();
        for(Review__c review : allReviewsList){
            system.debug('review ----'+review);
            revIdToStatus.put(review.Id, review.Status__c);
            revIdToRecommendation.put(review.Id, review.Recommendation__c);
            if(review.PanelUser__r.Reviewer__r.Name != null){
                revIdToReviewer.put(review.Id, review.PanelUser__r.Reviewer__r.Name);
            }else if(review.ownerId != null){
                revIdToReviewer.put(review.Id, review.Owner.Name);
            }else if(review.ReviewPanel__r.GroupName__c != null){
                revIdToReviewer.put(review.Id, review.ReviewPanel__r.GroupName__c);
            }else{
                revIdToReviewer.put(review.Id, '');
            }
            Boolean isReviewCompleted = false;
            if(review.Status__c == 'Review Completed'){
                isReviewCompleted = true;
            }
            reviewIdToCompletedFlag.put(review.Id, isReviewCompleted);
        }   
        system.debug('revIdToStatus ----'+revIdToStatus);
        system.debug('revIdToRecommendation ----'+revIdToRecommendation);
        system.debug('revIdToReviewer ----'+revIdToReviewer);
        system.debug('revIdToStepAppIdMap ----'+revIdToStepAppIdMap);
        system.debug('stepAppIdToHTMLMap ----'+stepAppIdToHTMLMap);
        system.debug('reviewIdToCompletedFlag ----'+reviewIdToCompletedFlag);

        stepAppIdToHTMLMap = generateHTML(reviewIdSet, revIdToStatus, revIdToRecommendation, revIdToReviewer, revIdToStepAppIdMap, stepAppIdToHTMLMap, reviewIdToCompletedFlag);
        system.debug('stepAppIdToHTMLMap---'+stepAppIdToHTMLMap);
        for(ReviewStepApplication__c rsa : rsaList){                            
            rsa.ReviewStatus__c = stepAppIdToHTMLMap.get(rsa.Id);            
        }
        if(rsaList.size() > 0){
            update rsaList;
        }
    }
    
    private static Map<Id, String> generateHTML(Set<Id> reviewIdSet, Map<Id, String> revIdToStatus, Map<Id, String> revIdToRecommendation, 
        Map<Id, String> revIdToReviewer, Map<Id, Id> revIdToStepAppIdMap, Map<Id, String> stepAppIdToHTMLMap, Map<Id, Boolean> reviewIdToCompletedFlag){
        for(Id revId : reviewIdSet){
            String status = revIdToStatus.get(revId);
            String revRecommendation = revIdToRecommendation.get(revId);
            String reviewerName = revIdToReviewer.get(revId);
            String tooltip = '', colorValue = '', iconCSSName = '',reviewDecision='';
            Boolean revCompleted = reviewIdToCompletedFlag.get(revId);
            system.debug('revCompleted---'+revCompleted);
            system.debug('status---'+status);
            system.debug('revRecommendation---'+revRecommendation);
            system.debug('reviewerName---'+reviewerName);            
            if(!String.isEmpty(revRecommendation) && revCompleted){ 
                if(revRecommendation.equalsIgnoreCase('Eligible') || revRecommendation.equalsIgnoreCase('Recommended') || revRecommendation.equalsIgnoreCase('Recommended for Award')){
                    colorValue = 'green';
                    iconCSSName = 'iconCompleted';
                    reviewDecision='Recommended';
                }else if(revRecommendation.equalsIgnoreCase('Rejected') || revRecommendation.equalsIgnoreCase('Ineligible') || revRecommendation.equalsIgnoreCase('Not Recommended')){
                    colorValue = 'red';
                    iconCSSName = 'iconRejected';
                    reviewDecision='Not Recommended';
                }else if(revRecommendation.equalsIgnoreCase('Review Declined') || revRecommendation.equalsIgnoreCase('Recommended for Award with Reservation')){
                    colorValue = 'yellow';
                    iconCSSName = 'iconUncertain';
                    reviewDecision='Declined';
                }else if(revRecommendation.equalsIgnoreCase('None')) {
            		colorValue = 'gray';
                    iconCSSName = 'iconNotStarted';
                    reviewDecision='Not Started';
                    tooltip = reviewerName + ': ' + status ;
                }
                //tooltip = reviewerName + ': ' + status + ' - ' + revRecommendation;
            }else{
                colorValue = 'gray';
                iconCSSName = 'iconNotStarted';
                if(String.isEmpty(revRecommendation) ){
                    revRecommendation = '';
                     reviewDecision='Not Started';
                }
                if(!String.isEmpty(status) && (status.equalsIgnoreCase('Declined Due To Conflict') || status.equalsIgnoreCase('Declined without Conflict'))){
            		colorValue = 'orange';
                    iconCSSName = 'iconDeclined';
                     reviewDecision='Declined';
                }
            }
            tooltip = reviewerName + ': ' + status + ' - ' + revRecommendation;
            // reviewer name: status - recommendation           
            String tempHTML = '<a onclick=\"window.open(\'/apex/'+AppUtils.getNamespacePrefix()+'ReviewAssignmentModalView?id='+revId+'\',\'Review View\',\'scrollbars=1,resizable=1,height=800px,width=900px\',\'_blank\')\" title=\"'+tooltip+'\">';
            
            if(reviewDecision=='Recommended'){
                tempHTML=tempHTML+'<i class=\"fa fa-thumbs-up\" aria-hidden=\"true\" ></i></a>&nbsp;';            
            }
            else if(reviewDecision=='Not Recommended'){
                tempHTML=tempHTML+'<i class=\"fa fa-thumbs-down\" aria-hidden=\"true\" ></i></a>&nbsp;';            
            }
            else if(reviewDecision=='Declined'){
                tempHTML=tempHTML+'<i class=\"fa fa-ban\" aria-hidden=\"true\" ></i></a>&nbsp;';            
            }
            else {
                tempHTML=tempHTML+'<i class=\"fa fa-question\" aria-hidden=\"true\" ></i></a>&nbsp;';            
            }
            Id stpeAppId = revIdToStepAppIdMap.get(revId);
            String iconHTML = stepAppIdToHTMLMap.get(stpeAppId);            
            if(!String.isEmpty(iconHTML)){
                iconHTML += tempHTML;
            }else{
                iconHTML = tempHTML;
            }
            stepAppIdToHTMLMap.put(stpeAppId, iconHTML);                
        }        
        return stepAppIdToHTMLMap;
    }
    
    private static Set<Id> getAllReviewIds(String revJSON){
        Set<Id> revIdSet = new Set<Id>();
        if(!String.isEmpty(revJSON)){
            List<String> tokenList = revJSON.split('#');
            for(String token : tokenList){
                List<String> tok = token.split(':');
                revIdSet.add(tok[0]);
            }
        }
        return revIdSet;
    }
    
    /*
        This method is used to generate the HTML content based on the updated status of the reviews 
    */
    private static String generateJSON(String oldJson, String newJson, Boolean isDelete){
        system.debug('oldJson --'+oldJson);
        system.debug('newJson --'+newJson);
        String finalJSON = '';
        Boolean found, alreadyProcessed;
        List<String> recordsProcessedList = new List<String>();
        List<String> oldTokensList = oldJson.split('#');   
        List<String> newTokensList = newJson.split('#');   
        for(String oldTok : oldTokensList){
            List<String> oldToken = oldTok.split(':');
            found = false;
            for(String tok : newTokensList){
                List<String> newToken = tok.split(':');
                if(newToken[0] == oldToken[0]){
                    found = true;
                    if(!isDelete){
                        finalJSON += newToken[0] + ':' + newToken[1] + '#';
                    }
                    break;
                }
            }
            if(!found){
                finalJSON += oldToken[0] + ':' + oldToken[1] + '#';
            }
            recordsProcessedList.add(oldToken[0]);
        }        
        for(String newTok : newTokensList){ // ID2, ID3
            List<String> newToken = newTok.split(':');
            alreadyProcessed = false;
            for(String recProcessed : recordsProcessedList){ // ID1, ID2
                if(recProcessed == newToken[0]){
                    alreadyProcessed = true;
                    break;
                }
            }
            if(!alreadyProcessed){
                finalJSON += newToken[0] + ':' + newToken[1] + '#';
            }         
        }        
        return finalJSON;
    }
}