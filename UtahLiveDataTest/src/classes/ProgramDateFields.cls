global class ProgramDateFields
    {

        public Map<String,Object> theMap { get; set;}
        public String jsonString {get;set;}
        public ProgramDateFields()
        {
            theMap = new Map<String,Object>{'StartDate' => new Map<String, String>{'Project Period Start date of Program'=>'StartDate__c'},
                                            'EndDate' => new Map<String, String>{'Project Period end date of Program'=>'EndDate__c'},
                                            'ActivationDate' => new Map<String, String>{'Program activation date'=>'Publisheddate__c'},
                                            'CreatedDate' => new Map<String, String>{' Program creation date'=>'CreatedDate'}
                                           };
            jsonString = JSON.serialize(theMap);
            System.debug('@@jsonString'+jsonString);
        }
    }